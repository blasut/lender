;;;; package.lisp

(defpackage #:lender
  (:use #:cl
        #:lucerne)
  (:import-from :ceramic.resource
                :define-resources
                :resource-directory)
  (:export :app
           :start-app))

