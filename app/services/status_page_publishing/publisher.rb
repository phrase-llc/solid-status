module StatusPagePublishing
  class Publisher
    CONTENT_TYPE = "text/html; charset=utf-8"
    CACHE_CONTROL = "public, max-age=60, s-maxage=60, stale-while-revalidate=60, stale-if-error=86400"

    def initialize(status_page, storage: Storage.build)
      @status_page = status_page
      @storage = storage
    end

    def publish
      @storage.write(
        key: self.class.object_key(@status_page.slug),
        body: render,
        content_type: CONTENT_TYPE,
        cache_control: CACHE_CONTROL
      )
    end

    def unpublish(slug)
      @storage.delete(key: self.class.object_key(slug))
    end

    def self.object_key(slug)
      "#{Rails.configuration.x.status_pages.s3_prefix}/#{slug}/index.html"
    end

    private

    def render
      ApplicationController.renderer.render(
        template: "public/status_pages/show",
        layout: false,
        assigns: { status_page: @status_page, incidents: incidents, published_at: Time.current }
      )
    end

    def incidents
      @status_page.incidents.includes(:incident_entries).order(started_at: :desc)
    end
  end
end
