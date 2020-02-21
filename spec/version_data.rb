def three_versions(facts)
  versions =
    case facts[:osfamily]
    when 'FreeBSD'
      case facts[:operatingsystemmajrelease]
      when '10'
        %w[34 35]

      end
    when 'OpenBSD'
      case facts[:kernelversion]
      when '5.8'
        '3.4.3'

      when '5.9'
        '3.4.4'

      when '6.0'
        '3.5.2'

      when '6.1'
        '3.6.0p0'

      end
    when 'Debian'
      case facts[:operatingsystemmajrelease]
      when '8'
        '3.4'

      end
    when 'CentOS'
      case facts[:operatingsystemmajrelease]
      when '7'
        '3'

      end
    when 'RedHat'
      case facts[:operatingsystemmajrelease]
      when '7'
        '3'

      when 'Archlinux'
        '3'

      end
    end
  Array(versions).flatten
end

def two_versions(facts)
  versions =
    case facts[:osfamily]
    when 'FreeBSD'
      case facts[:operatingsystemmajrelease]
      when '10'
        ['27']

      end
    when 'OpenBSD'
      case facts[:kernelversion]
      when '5.8'
        '2.7.10'

      when '5.9'
        '2.7.11'

      when '6.0'
        '2.7.12'

      when '6.1'
        '2.7.13p0'

      end
    when 'Debian'
      case facts[:operatingsystemmajrelease]
      when '8'
        '2.7'

      end
    when 'Archlinux'
      '2'
    end
  Array(versions).flatten
end
