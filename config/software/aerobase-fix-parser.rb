name "aerobase-fix-parser"
default_version "1.0.0"

skip_transitive_dependency_licensing true

license :project_license

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem "uninstall parser" \
      " --version '3.3.2.0'" \
      " --bindir '#{install_dir}/embedded/bin'"
  
  gem "uninstall rubocop-ast" \
      " --version '1.31.3'" \
      " --bindir '#{install_dir}/embedded/bin'"
    
  gem "install parser" \
      " --version '3.3.0.5'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      "  --no-document", env: env
end