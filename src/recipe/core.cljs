(ns recipe.core
  (:require [om.core :as om :include-macros true]
            [om-tools.core :refer-macros [defcomponent]]
            [om-tools.dom :as dom :include-macros true]
            [clojure.string :as string]
            [recipe.rest :refer [json-xhr]]
            [recipe.pretty :as pretty]
            [recipe.views.app :as app]))

(enable-console-print!)

(def app-state (atom {}))

(defn update-data []
  (swap! app-state update-in [:retrieving-on] #(or % (js/Date.)))
  (swap! app-state update-in [:retrieving-seconds] inc)
  (json-xhr {
    :method :get
    :url (:base-url @app-state)
    :complete (fn [stats]
                (when stats
                  (swap! app-state assoc :stats stats
                                         :retrieving-on nil
                                         :retrieving-seconds 0
                                         :retrieved-on (js/Date.))))}))

(om/root
  app/recipe-view
  app-state
  {:target (. js/document (getElementById "app"))})

(defn ^:export setStatsUrl [url]
  (swap! app-state update-in [:refresh-cookie]
    (fn [old-cookie]
      (println (str "setting stats url to " url))
      (when old-cookie
        (println (str "Clearing old cookie: " old-cookie))
        (js/clearInterval old-cookie))
      (js/setInterval update-data 1000)))
  (swap! app-state (constantly {:base-url url}))
  (js/setTimeout update-data 1))

(setStatsUrl "/Intellispace/stats.json")
