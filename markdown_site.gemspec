require_relative 'lib/markdown_site/version'

Gem::Specification.new do |s|
  s.name = 'markdown_site'
  s.version = MarkdownSite::Version
  s.author = ['Zhuang Biaowei']
  s.email = ['zbw@kaiyuanshe.org']
  s.homepage = 'https://github.com/markdown-world/markdown_site'
  s.license = 'Apache-2.0'
  s.summary = 'A markdown-based site management module.'
  s.files = Dir.glob('{lib,test}/**/*')
  s.require_path = 'lib'
  s.required_ruby_version = '>= 2.5.0'
  s.add_runtime_dependency 'tomlrb', '~>2.0.0'
  s.add_runtime_dependency 'markdown_extension', '~>0.1.6'
  s.add_runtime_dependency 'liquid', '~>5.4.0'
end
