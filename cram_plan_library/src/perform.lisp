;;; Copyright (c) 2012, Lorenz Moesenlechner <moesenle@in.tum.de>
;;; All rights reserved.
;;; 
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;; 
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;     * Redistributions in binary form must reproduce the above copyright
;;;       notice, this list of conditions and the following disclaimer in the
;;;       documentation and/or other materials provided with the distribution.
;;;     * Neither the name of the Intelligent Autonomous Systems Group/
;;;       Technische Universitaet Muenchen nor the names of its contributors 
;;;       may be used to endorse or promote products derived from this software 
;;;       without specific prior written permission.
;;; 
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.

(in-package :plan-lib)

(def-goal (perform ?action-designator)
  (let ((matching-process-modules (matching-process-module-names ?action-designator)))
    (unless matching-process-modules
      (fail "No process modules found for executing designator ~a" ?action-designator))
    ;; Rethrow the first error in the composite-failure. This is
    ;; necessary to keep the high-level plans working. For instance,
    ;; if perception fails, plans expect an OBJECT-NOT-FOUND failure,
    ;; not a COMPOSITE-FAILURE.
    (with-failure-handling
        ((composite-failure (failure)
           (fail (car (composite-failures failure)))))
      (try-each-in-order (module matching-process-modules)
        (perform-on-process-module module ?action-designator)))))

(def-goal (perform-on-process-module ?module ?action-designator)
  (pm-execute ?module ?action-designator))

(def-goal (monitor-action ?action-designator)
  (let ((matching-process-modules (matching-process-module-names ?action-designator)))
    (monitor-process-module (car matching-process-modules) :designators (list ?action-designator))
    ;; (par-loop (module matching-process-modules)
    ;;   (monitor-process-module module :designators (list ?action-designator)))
    ))
