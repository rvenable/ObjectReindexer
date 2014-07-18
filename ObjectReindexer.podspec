Pod::Spec.new do |s|
  version = "1.0"

  s.name         = "ObjectReindexer"
  s.version      = version
  s.summary      = "ObjectReindexer is a utility class for reindexing data objects."
  s.homepage     = "https://github.com/rvenable/ObjectReindexer"

  s.license      = {
    :type => 'Epicfox',
    :text => <<-LICENSE
              Copyright (c) 2012 Epicfox. All rights reserved.
    LICENSE
  }

  s.author       = { "Richard Venable" => "richard@epicfox.com" }
  s.source       = { :git => "https://github.com/rvenable/ObjectReindexer", :tag => version }
  s.platform     = :ios, '6.0'
  s.source_files = 'ObjectReindexer/**/*.{h,m}'
  s.framework  = 'Foundation'
  s.requires_arc = true

end
