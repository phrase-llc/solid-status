require "fileutils"

module StatusPagePublishing
  class LocalStorage
    def initialize(root:)
      @root = Pathname(root)
    end

    def write(key:, body:, content_type:, cache_control:)
      path = @root.join(key)
      FileUtils.mkdir_p(path.dirname)
      File.binwrite(path, body)
    end

    def delete(key:)
      FileUtils.rm_f(@root.join(key))
    end
  end
end
