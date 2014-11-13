(ns recipe.views.components
  (:require [om.core :as om :include-macros true]
            [om-tools.core :refer-macros [defcomponent]]
            [om-tools.dom :as dom :include-macros true]
            [clojure.string :as string]
            [recipe.pretty :as pretty]))

(defn anchor [id]
  (dom/a {:id id}))

(defn font-awesome-icon
  ([icon-class] (font-awesome-icon icon-class {}))
  ([icon-class attrs]
    (dom/i (assoc attrs :class (dom/class-set  {"fa " 1 icon-class 1})) nil)))

(defn banner [{:keys [title sub-title icon-class banner-class]}]
  (dom/div {:class (str "banner " banner-class)}
    (dom/h1 title
      (when icon-class
        (font-awesome-icon icon-class)))
    (when sub-title
      (dom/h2 sub-title))))

(defn page-heading [{:keys [section-name icon-class]}]
  (dom/h1 nil
    (dom/span section-name)
    (when icon-class
      (font-awesome-icon icon-class))))

(defn section-heading [{:keys [section-name icon-class]}]
  (dom/h2 nil
    (dom/span section-name)
    (when icon-class
      (font-awesome-icon icon-class))))

(defcomponent card [{:keys [id text source content]} owner]
  (render [_]
    (dom/div {:id id
              :class (str "card " (when source (str "source" source)))}
             (when text
               (dom/h1 nil text))
             content)))

(defcomponent queue [{:keys [title id depth capacity]} owner]
  (render [_]
    (dom/div {:id id
              :class "queueItemContainer"
              :title title}
      (when-not (zero? capacity)
        (let [width  (-> (* 10000 .75) (/ capacity) js/Math.floor (/ 100) (str "%"))
              margin (-> (* 10000 .25) (/ capacity) js/Math.floor (/ 100) (str "%"))
              style {:width width :margin-right margin}
              summary
                (dom/p {:id "summary"}
                  (str title ":")
                  (dom/b (pretty/number depth))
                  "/"
                  (dom/b (pretty/number capacity)))
              queue-divs (->> (range capacity)
                              (map #(dom/div {:style style, :class (if (< % depth) "y")})))]
            (cons summary queue-divs))))))

(defn stale-indicator [{:keys [age-seconds max-age-seconds stale-dom-fn normal-dom-fn]}]
  (when age-seconds
    (let [is-stale (> age-seconds max-age-seconds)]
        (if is-stale
          (when stale-dom-fn (stale-dom-fn))
          (when normal-dom-fn (normal-dom-fn))))))
