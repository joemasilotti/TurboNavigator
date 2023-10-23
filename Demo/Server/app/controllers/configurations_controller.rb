class ConfigurationsController < ApplicationController
  def ios_v1
    render json: {
      settings: [],
      rules: [
        {
          patterns: [
            "/recede_historical_location"
          ],
          properties: {
            presentation: "pop"
          },
          comment: "Dismiss a modal or pop a controller with `recede_or_redirect_to` via turbo-rails."
        },
        {
          patterns: [
            "/refresh_historical_location"
          ],
          properties: {
            presentation: "refresh"
          },
          comment: "After dismissing or popping, refresh the visible screen with `refresh_or_redirect_to`."
        },
        {
          patterns: [
            "/resume_historical_location"
          ],
          properties: {
            presentation: "none"
          },
          comment: "Skip navigation with `resume_or_redirect_to` via turbo-rails."
        },
        {
          patterns: [
            "/new$",
            "/edit$",
            "/modal"
          ],
          properties: {
            context: "modal"
          },
          comment: "Present forms and custom modal path as modals."
        },
        {
          patterns: [
            "^/$"
          ],
          properties: {
            presentation: "clear_all"
          },
          comment: "Reset navigation stacks when visiting root page."
        }
      ]
    }
  end
end
