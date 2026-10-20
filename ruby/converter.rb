require 'asciidoctor-pdf'

class PDFConverterCustom < (Asciidoctor::Converter.for 'pdf')
    register_for 'pdf'

    def convert_admonition node
        type = node.attr 'name'
        key_prefix = %(admonition_#{type}_)
        return super if (entries = theme.each_pair.select {|name, val| name.start_with? key_prefix }).empty?
        save_theme do
            entries.each {|name, val| theme[%(admonition_#{name.to_s.delete_prefix key_prefix})] = val }
            super
        end
    end


    def ink_title_page doc
        ink_title_page_logo
        ink_title_page_subtitle doc
        ink_title_page_main_title doc
        ink_title_page_authors doc
    end

    
    def convert_document doc
        original_set_attr = doc.method(:set_attr)

        doc.define_singleton_method(:set_attr) do |name, value, *args|
            if name == 'page-number' && value.is_a?(String) &&
            value.match?(/\A[ivxlcdm]+\z/)

                valores = {
                    'i' => 1, 'v' => 5, 'x' => 10,
                    'l' => 50, 'c' => 100, 'd' => 500, 'm' => 1000
                }

                numero = 0
                anterior = 0

                value.reverse.each_char do |caracter|
                    atual = valores[caracter]
                    numero += atual < anterior ? -atual : atual
                    anterior = atual
                end

                value = Asciidoctor::PDF::RomanNumeral.new(
                    numero - 1, :lower
                ).to_s if numero > 1
            end

            original_set_attr.call(name, value, *args)
        end

        output = super
        ink_content_page_headers doc
        output
    end


    # Quebra de pagina automatico
    def convert_section node
        if node.level == 1 && !at_page_top?
            start_new_page
        end

        super
    end

    private
    
    def ink_title_page_logo
        ipc_path = ::File.expand_path '../resources/images/ipc.svg', __dir__
        return unless ::File.exist? ipc_path

        logo_x = 55
        logo_height = 67
        logo_top = page_height - 21

        canvas do
            image ipc_path,
                at: [logo_x, logo_top],
                height: logo_height
        end
    end
    
    def ink_title_page_subtitle doc
        move_cursor_to page_height * 0.75

        theme_font :title_page_school do
            ink_prose "<strong>Escola Superior de Tecnologia e Gestão</strong>",
                align: :center, margin: 0
        end

        move_down 55

        theme_font :title_page_course do
            ink_prose 'Licenciatura em Engenharia Informática',
                align: :center, margin: 0
        end

        move_down 35

        theme_font :title_page_subject do
            ink_prose 'Gestão de Sistemas e Redes',
                align: :center, margin: 0
        end

        move_down 35

        theme_font :title_page_academic_year do
            ink_prose "Ano Letivo #{doc.attr('ano-letivo')}",
                align: :center, margin: 0
        end
    end

    def ink_title_page_main_title doc
        move_cursor_to page_height * 0.40
        doctitle = doc.doctitle partition: true
        theme_font :title_page_title do
            ink_prose doctitle.main,
                align:       :center,
                color:       theme.title_page_title_font_color,
                line_height: 1.2,
                margin:      0
        end
    end

    def ink_title_page_authors doc
        move_cursor_to page_height * 0.30
        theme_font :title_page_date do
            date_text = "Elaborado em: #{doc.attr('revdate')}"
            ink_prose date_text, align: :center, margin: 0
            authors_list = doc.authors.map { |a| a.name }.join('<br>')
            ink_prose authors_list, align: :center, margin: 0
        end
    end

    def ink_content_page_headers doc
        logo_path = ::File.expand_path '../resources/images/estgoh.svg', __dir__
        return unless ::File.exist? logo_path

            header_params = build_header_params logo_path, doc
            (2..page_count).each do |pnum|
                go_to_page pnum
                ink_single_page_header header_params
            end
    end

    def build_header_params logo_path, doc
        margin_top  = (theme.page_margin[0] || 72).to_f
        margin_lr   = (theme.page_margin[1] || 72).to_f
        logo_height = 60
        {
            logo_path:   logo_path,
            margin_lr:   margin_lr,
            logo_height: logo_height,
            band_top: page_height - margin_top + logo_height + 10,
            title_y: page_height - margin_top + logo_height * 0.8,
            usable_w:    page_width - margin_lr * 2,
            title_text:  doc.doctitle || '',
        }
    end

    def ink_single_page_header p
        canvas do
            image p[:logo_path], at: [p[:margin_lr], p[:band_top]], height: p[:logo_height]

            font (theme.base_font_family || 'Lato'),
                size: (theme.header_font_size || 9), style: :normal do
                fill_color theme.header_font_color || '7F8C8D'
                text_box p[:title_text],
                    at:       [p[:margin_lr], p[:title_y]],
                    width:    p[:usable_w],
                    height:   14,
                    align:    :right,
                    overflow: :truncate
            end
        end
    end
end