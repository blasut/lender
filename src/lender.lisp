;;;; lender.lisp

(in-package #:lender)
(annot:enable-annot-syntax)

;;; App resources

(define-resources :lender ()
  (assets #p"assets/")
  (templates #p"templates/"))

;;; Helpers

(defun parse-float (string)
  (with-input-from-string (in string)
  (read in)))

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


;;; Routes

@route app "/"
(defview index ()
  (let ((balances (carola:get-available-account-balances)))
    (render-template (+index+)
                     :balances balances)))

@route app (:post "/loans")
(defview loans ()
  (with-params (currency amount duration auto-renew lending-rate)
     (carola:create-loan-offer (carola:make-currency currency)
                                 :amount amount
                                 :duration duration
                                 :auto-renew auto-renew
                                 :lending-rate (float (/ (parse-float lending-rate) 100)))
    (redirect "/")))


;;; Startup

(defvar *port* 40000)

(defun start-app ()
  (start app :port *port*))

(defun run ()
  (let ((window (ceramic:make-window :url (format nil "http://localhost:~D/" *port*))))
    (ceramic:show-window window)
    (start-app)))

(ceramic:define-entry-point :lender ()
  (run))
