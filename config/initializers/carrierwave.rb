module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.write(current_path){ self.quality(percentage) }
        img = yield(img) if block_given?
        img
      end
    end
  end
end