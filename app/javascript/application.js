// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//import "@hotwired/turbo-rails"
//import "./controllers"

import React from "react"
import ReactDOM from "react-dom/client"
import LandingPage from "./components/LandingPage"

const rootElement = document.getElementById("react-root")

if (rootElement) {
  const root = ReactDOM.createRoot(rootElement)
  root.render(<LandingPage />)
}
