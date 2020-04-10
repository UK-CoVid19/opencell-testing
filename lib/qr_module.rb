require 'rqrcode'

module QrModule
  attr_accessor :qr_attr

  def self.extended(base)
    base.class_eval do
      def qr_code
        qrcode = RQRCode::QRCode.new(self.send(self.class.qr_attr))
        png = qrcode.as_png(
            bit_depth: 1,
            border_modules: 4,
            color_mode: ChunkyPNG::COLOR_GRAYSCALE,
            color: 'black',
            file: nil,
            fill: 'white',
            module_px_size: 6,
            resize_exactly_to: false,
            resize_gte_to: false,
            size: 400
        )
        return png
      end
    end
  end

  def qr_for(attr)
    unless(self.column_names.include? attr.to_s)
      raise ArgumentError.new  "unrecognised attribute passed #{attr}"
    end
    self.qr_attr = attr
  end

end