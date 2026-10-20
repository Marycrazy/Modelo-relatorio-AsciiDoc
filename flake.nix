{
    description = "Ruby development environment";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs = inputs@{ self, flake-parts, ... }:

    let
        projectRoot = "$PWD/";
        gemDir = "${projectRoot}/ruby/.gems";
    in

    flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

        perSystem = { pkgs, ... }: {
            devShells.default = pkgs.mkShell {
                buildInputs = with pkgs; [
                    asciidoctor-with-extensions
                    ruby_4_0
                    antora
                    graphicsmagick
                    pkg-config
                    tree
                    fzf
                ];

                shellHook = ''
                    export GEM_HOME="${gemDir}"
                    export GEM_PATH=$GEM_HOME
                    export PATH="$GEM_HOME/bin:$PATH"

                    export ASCIIDOC_FONTS_DIR="${projectRoot}/resources/fonts"
                    export ASCIIDOC_THEMES_DIR="${projectRoot}/resources/themes"
                    export ASCIIDOC_IMAGES_DIR="${projectRoot}/resources/images"

                    mkdir -p .vscode
                    cat > ${projectRoot}/.vscode/settings.json << EOF
                        {
                            "nixEnvSelector.nixFile": "${projectRoot}/shell.nix",
                            "asciidoc.preview.asciidoctorAttributes": {
                                "source-highlighter": "highlightjs",
                                "allow-uri-read": ""
                            },
                        }
                    EOF

                    gem install bundler -v 4.0.10

                    cat > ${projectRoot}/ruby/Gemfile << EOF
                        source 'https://rubygems.org'
                        gem 'bigdecimal'
                        gem 'logger'
                        gem 'asciidoctor-pdf'
                        gem 'prawn-gmagick'
                        gem 'rouge'
                        gem 'coderay'
                        gem 'pygments.rb'
                    EOF

                    (
                        cd ./ruby &&
                        bundle install
                    )

                    echo "Environment ready!"
                    clear_screen=true
                    for number in {5..1}; do
                        echo "Clearing screen in $number seconds... (Press any key to cancel)"
                        if read -r -t 1 -n 1; then
                            echo -e "\nScreen clear cancelled!"
                            clear_screen=false
                            break
                        fi
                    done
                    if $clear_screen; then
                        clear
                    fi

                    alias cls='clear'

                    build() {
                        local doc
                        doc=$(ls *.adoc | fzf) || return
                        asciidoctor-pdf -r ./ruby/converter.rb -D out "$doc"
                    }
                '';
            };
        };
    };
}