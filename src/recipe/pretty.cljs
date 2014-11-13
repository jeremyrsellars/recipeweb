(ns recipe.pretty
  (:require [clojure.string :as string]))

(enable-console-print!)

(defn day-of-week-name[dt]
  (-> dt
      js/Date.
      .getDay
      (["Mon","Tue","Wed","Thurs","Fri","Sat","Sun"])))

(defn reduced-precision [n]
  (cond (> n 1000000) (-> n (/ 1000000) js/Math.floor (str "M"))
        (> n 1000)    (-> n (/ 1000)    js/Math.floor (str "K"))
        :else (str n)))

(defn- seconds-between [start-on end-on]
  (let [start-ms (.getTime start-on)
        end-ms   (.getTime end-on)]
    (/ (- end-ms start-ms) 1000)))

(defn datetimeoffset [dto-string]
  (when dto-string
    (let [dt (js/Date. dto-string)]
      (if (> (js/Math.abs (seconds-between dt (js/Date.))) 28800) (string/replace dto-string #"T|\..*" " ")
          (.toLocaleTimeString dt)))))

(defn reduced-precision-time-between [start-on end-on]
  (let [s (seconds-between start-on end-on)]
    (cond (> s 86400 * 2) (str (/ (js/Math.floor (/ s 8640)) 10) "d")
          (> s 3600)      (str (js/Math.floor (/ s 3600)) "h")
          (> s 60)        (str (js/Math.floor (/ s 60)) "m")
          :else           (str (js/Math.floor s) "s"))))

(defn number [n]
  (if (number? n)
    (.toLocaleString n 'en-US', #js {"useGrouping" true})
    n))

(defn reduced-precision-time-ago [time-string]
  (reduced-precision-time-between (js/Date. time-string)  (js/Date.)))

(defn reduced-precision-time-until [time-string]
  (reduced-precision-time-between (js/Date.) (js/Date. time-string)))

(defn datetimeoffset-ago [dto-string]
  (str (datetimeoffset dto-string) " (" (reduced-precision-time-ago dto-string) " ago)"))

(defn datetimeoffset-until [dto-string]
  (str (datetimeoffset dto-string) " (+" (reduced-precision-time-until dto-string) ")"))
