(defproject recipe "0.1.0-SNAPSHOT"
  :description "Meals for a rich life"
  :url "http://hungryadelaide.rathertasty.com/recipes/"

  :dependencies [[org.clojure/clojure "1.6.0"]
                 [org.clojure/clojurescript "0.0-2356"]
                 [org.clojure/core.async "0.1.267.0-0d7780-alpha"]
                 [com.cognitect/transit-cljs "0.8.188"]
                 [prismatic/om-tools "0.3.6"]
                 [om "0.7.1"]]

  :plugins [[lein-cljsbuild "1.0.4-SNAPSHOT"]
            [lein-simpleton "1.3.0"]]

  :source-paths ["src"]

  :cljsbuild {
    :builds [{:id "dev"
              :source-paths ["src"]
              :compiler {
                :output-to "recipe-dev.js"
                :output-dir "out/dev"
                :optimizations :none
                :source-map "recipe-dev.js.map"
                :pretty-print false
                :preamble ["react/react.min.js"]
                :externs ["react/externs/react.js"]}}
             {:id "release"
              :source-paths ["src"]
              :compiler {
                :output-to "recipe.js"
                :output-dir "out/release"
                :optimizations :advanced
                :source-map "recipe.js.map"
                :pretty-print false
                :preamble ["react/react.min.js"]
                :externs ["react/externs/react.js"]}}]})
