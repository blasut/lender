;;;; lender.asd

(asdf:defsystem #:lender
  :description "Describe lender here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:ceramic
               #:lucerne
               #:carola)
  :serial t
  :components ((:file "package")
               (:module "assets"
                :components
                ((:module "css"
                  :components
                  ((:static-file "style.css")))
                 (:module "js"
                  :components
                  ((:static-file "scripts.js")))))
               (:module "src"
                :serial t
                :components
                ((:file "lender")))))

