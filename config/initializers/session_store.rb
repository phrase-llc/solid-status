Rails.application.config.session_store :active_record_store, key: "_solid_status_session", secure: Rails.env.production?, expire_after: 16.hours
