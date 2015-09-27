;;;; package.lisp

(defpackage #:lender
  (:use #:cl
        #:carola
        #:lucerne)
  (:import-from :ceramic.resource
                :define-resources
                :resource-directory)
  (:export :app
           :start-app))

