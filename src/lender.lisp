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


;;; Routes

@route app "/"
(defview index ()
  (render-template (+index+)))


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
