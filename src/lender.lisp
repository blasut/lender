;;;; lender.lisp

(in-package #:lender)
(annot:enable-annot-syntax)

;;; App resources

(define-resources :lender ()
  (assets #p"assets/")
  (templates #p"templates/"))


;;; App

(defapp app
  :middlewares ((clack.middleware.static:<clack-middleware-static>
                 :root (resource-directory 'assets)
                 :path "/static/")))

;;; Templates

(djula:add-template-directory
 (resource-directory 'templates))

(defparameter +index+
  (djula:compile-template* "index.html"))


;;; Helpers

(defun parse-float (string)
  (if (stringp string)
      (with-input-from-string (in string)
        (read in))
      string))

(defun calculate-yearly-rate (rate)
  (let ((rate (parse-float rate)))
    (* rate 365)))

(defun normalize-rate (order)
  (setf (getf order :rate) (* 100 (parse-float (getf order :rate)))))

(defun get-open-loan-orders ()
  (loop for coin in (carola:get-open-loan-orders) append
       (loop for order in (cdr coin) collect (alexandria:flatten
                                              (let* ((order (alexandria:flatten order))
                                                    (yr (calculate-yearly-rate (getf order :rate))))
                                                (normalize-rate order)
                                                (append order (list (list :coin (car coin))
                                                                    (list :yearly-rate yr))))))))
(defun get-active-loans ()
  (loop for coin in (carola:get-active-loans) append
       (loop for order in (cdr coin) collect (alexandria:flatten
                                              (let* ((order (alexandria:flatten order))
                                                     (yr (calculate-yearly-rate (getf order :rate))))
                                                (normalize-rate order)
                                                (append order (list (list :type (car coin))
                                                                    (list :yearly-rate yr))))))))


;;; Routes

@route app "/"
(defview index ()
  (let ((balances (carola:get-available-account-balances))
        (lol (sleep 1))
        (open-orders (get-open-loan-orders))
        (lol2 (sleep 1))
        (active-loans (get-active-loans)))
    (render-template (+index+)
                     :balances balances
                     :open-orders open-orders
                     :active-loans active-loans)))

@route app (:post "/loans")
(defview loans ()
  (with-params (currency amount duration auto-renew lending-rate)
     (carola:create-loan-offer (carola:make-currency currency)
                                 :amount amount
                                 :duration duration
                                 :auto-renew auto-renew
                                 :lending-rate (write-to-string (float (/ (parse-float lending-rate) 100))))
    (redirect "/")))


;;; Startup

(defvar *port* 40000)

(defun start-app ()
  (start app :port *port*))

(defun stop-app ()
  (stop app))

(defparameter *window* "")

(defun run ()
  (let ((window (ceramic:make-window :url (format nil "http://localhost:~D/" *port*) :resizablep t)))
    (ceramic:show-window window)
    (setf *window* window)
    (start-app)))

(defun kill ()
  (stop-app)
  (ceramic:destroy-window *window*))

(ceramic:define-entry-point :lender ()
  (run))
