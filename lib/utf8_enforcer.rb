# String extensions to convert any encoding to utf8
class String
  def try_convert_from_encoding_to_utf8!(encoding)
    original_encoding = self.encoding
    begin
      force_encoding(encoding).encode!(Encoding::UTF_8)
      true
    rescue
      force_encoding(original_encoding)
      false
    end
  end

  def to_utf8!
    if force_encoding(Encoding::UTF_8).valid_encoding?
      return encode!(Encoding::UTF_8, invalid: :replace, replace: '?')
    end
    return self if try_convert_from_encoding_to_utf8!(Encoding::ISO_8859_1)
    return self if try_convert_from_encoding_to_utf8!(Encoding::Windows_1252)
    return self if try_convert_from_encoding_to_utf8!(Encoding::Windows_1252)
    encode!(Encoding::UTF_8, invalid: :replace, replace: '?')
  end

  def to_utf8
    dup.to_utf8!
  end
end