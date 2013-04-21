require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Feed
  class Cfcard < Yapra::Plugin::MechanizeBase
    VERSION = "0.0.1"
    def run(data)
      total = get_current_total

      x = with do|info|
        diff = total - info[:total]

        if diff < 0 then
          { total: total, diff: total }
        else
          { total: total, diff: diff }
        end
      end

      [ x ]
    end

    private
    def with(&f)
      info = Marshal.load(File.read(config['info_file'])) rescue { total: 0, created_at: Time.at(0) }

      ret = f[info]

      File.open(config['info_file'], 'w') do|io|
        io.print Marshal.dump(ret)
      end

      ret
    end

    def get_current_total
      login_page = agent.get('https://cfcard.ufit.ne.jp/cfwebiew_pc/onLogon.asp')
      login_page.form_with(name: 'Form1') do|form|
        form['UserID'] = config['username']
        form['Pass']   = config['password']
        b = form.button_with(name: 'submit1')
        form.click_button(b)
      end
      page = agent.get('https://cfcard.ufit.ne.jp/cfwebiew_pc/onZandaka.asp')
      prices = agent.page.root.css('td.unnamed1').
        map(&:text).
        grep(/円$/).
        map{|x| x.gsub(/,|円/,'').to_i }[0]
    end
  end
end
