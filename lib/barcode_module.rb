require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
require 'chunky_png'

module BarcodeModule
  attr_accessor :barcode_attr

  def self.extended(base)
    base.class_eval do
      def barcode
        barcode = Barby::Code128B.new(self.send(self.class.barcode_attr))
        png = barcode.to_png(height: 200, margin: 5, xdim: 4)
        b64 = Base64.encode64(png)
        data_uri = "data:image/png;base64,#{b64}"
        data_uri
      end
    end
  end

  def barcode_for(attr)
    unless(self.column_names.include? attr.to_s)
      raise ArgumentError.new  "unrecognised attribute passed #{attr}"
    end
    self.barcode_attr = attr
  end

end