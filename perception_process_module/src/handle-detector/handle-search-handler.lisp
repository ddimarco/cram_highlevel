;;; Copyright (c) 2012, Georg Bartels <georg.bartels@in.tum.de>
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

(in-package :perception-process-module)

(defvar *handle-detector-action* nil
  "Action client for handle detector.")

(defclass handle-perceived-object (perceived-object)
  ())

(defun init-handle-detector ()
  (setf *handle-detector-action*
        (actionlib:make-action-client
         "handle_detector/detect"
         "handle_detection/HandleDetectionAction")))

(register-ros-init-function init-handle-detector)

(def-object-search-function handle-search-function handle-detector
    (((type handle)) desig perceived-object)
  (declare (ignore desig perceived-object))
  (with-fields (handles)
      (actionlib:send-goal-and-wait
       *handle-detector-action*
       (actionlib:make-action-goal *handle-detector-action*
         number_of_handles 3))
    (when (> (length handles) 0)
      (assert (eql (length handles) 3))
       (let ((pose (tf:msg->pose-stamped (elt handles 0))))
         (list
          (make-instance 'handle-perceived-object
            :pose (tf:copy-pose-stamped
                   (tf:transform-pose
                    ;; hack(moesenle): remove the time stamp because
                    ;; tf fails to transform for some weird reason
                    *tf* :pose (tf:copy-pose-stamped pose :stamp 0.0)
                    :target-frame "map")
                   :stamp 0.0)
            :probability 1.0))))))