# rubocop:disable all
namespace :whitelist_domain_list do
  desc "Insert whitlist domains into database"
  task :import => :environment do
    domian_list = File.readlines("data/buyer-email-domains.txt")
    url_data = []
    domian_list.each { |url|
      list = { 
        'url': url.squish,
        'active': true,
        'created_at': DateTime.current,
        'updated_at': DateTime.current
      }
      url_data.push(list)
    }
    DomainsWhiteList.insert_all(url_data)
  end
end
# rubocop:enable all