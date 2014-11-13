(ns recipe.views.app
  (:require [om.core :as om :include-macros true]
            [om-tools.core :refer-macros [defcomponent]]
            [om-tools.dom :as dom :include-macros true]
            [clojure.string :as string]
            [recipe.pretty :as pretty]
            [recipe.views.components :as c]))

(defcomponent recipe-view [app owner]
  (render [_]
    (let [stats (get app :stats)
          header (c/page-heading {:section-name "recipe"})
          retrieving-on (-> app :retrieving-on)
          retrieving-on-pretty (when retrieving-on (-> retrieving-on (.toISOString) (pretty/datetimeoffset-ago)))
          retrieved-on (-> app :retrieved-on)
          retrieved-on-pretty (when retrieved-on (-> retrieved-on (.toISOString) (pretty/datetimeoffset-ago)))]
      (if-not stats
        (dom/div
          header
          (c/stale-indicator {:age-seconds (get app :retrieving-seconds)
                              :max-age-seconds 5
                              :stale-dom-fn (constantly (c/banner {:title "Fetching recipe information "
                                                                   :sub-title (str "No data since " retrieving-on-pretty)
                                                                   :icon-class "fa-circle-o-notch fa-spin"
                                                                   :banner-class 'error}))
                              :normal-dom-fn (constantly (c/banner {:title "Fetching recipe information "
                                                                    :icon-class "fa-circle-o-notch fa-spin"}))}))
        (dom/div
          header
          (c/stale-indicator {:age-seconds (get app :retrieving-seconds)
                              :max-age-seconds 5
                              :stale-dom-fn (constantly (c/banner {:title "Fetching recipe Information "
                                                                   :sub-title (str "No data since " retrieved-on-pretty)
                                                                   :icon-class "fa-refresh fa-spin error"
                                                                   :banner-class 'warning}))
                              :normal-dom-fn (constantly (dom/p {:id 'retrieved-on}
                                                           "Details as of "
                                                           (dom/b (-> app :retrieved-on (.toLocaleString)))))}))))))
