# rubocop:disable all
namespace :organisations do
  desc "Import organisations into database"
  task :import => :environment do
    xlsx = Roo::Excelx.new('data/Customers.xlsx')
    insert_data = []
    xlsx.sheet(1).each_row_streaming(pad_cells: true, offset: 1) do |row|
      list = { 
        'supllier_name': row[1].value,
        'active': row[11].value != 'Active'? false:true, 
        'created_at': DateTime.current,
        'updated_at': DateTime.current
      }
      insert_data.push(list)
    end
    Organisation.delete_all
    Organisation.insert_all(insert_data)
  end

  task :remove_duplicates => :environment do
    delete = 'DELETE FROM
                organisations a
                  USING organisations b
              WHERE
                a.id < b.id
              AND a.supllier_name = b.supllier_name;'
  end
end
# rubocop:enable all