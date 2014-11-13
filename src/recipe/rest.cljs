(ns recipe.rest
  (:require [cognitect.transit :as t]
            [goog.events :as events])
  (:import [goog.net XhrIo]
           goog.net.EventType
           [goog.events EventType]))

(enable-console-print!)

;; XHR

(def ^:private meths
  {:get "GET"
   :put "PUT"
   :post "POST"
   :delete "DELETE"})

(defn read-json [json]
  (let [r (t/reader :json-verbose)]
    (t/read r json)))

(defn json-xhr [{:keys [method url data complete error]}]
  (let [xhr (XhrIo.)]
    (events/listen xhr goog.net.EventType.COMPLETE
      (fn [e]
        (->> (.getResponseText xhr)
             (read-json)
             ((or complete #(.log js/console "no :complete callback defined" %))))))
    (events/listen xhr goog.net.EventType.ERROR
      (fn [e]
        ((or error #(.log js/console "no error callback defined" %)) e)))
    (. xhr
      (send url (meths method) (when data (pr-str data))
        #js {"Content-Type" "application/edn"}))
    :async))
