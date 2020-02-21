# frozen_string_literal: true

# MySQLでutf8mb4を利用する場合、ROW_FORMART=DYNAMICが必要
# ※my.cnfへの設定追加も必要なので注意
#
# refer: http://3.1415.jp/mgeu6lf5/
ActiveSupport.on_load :active_record do
  module ActiveRecord::ConnectionAdapters
    class AbstractMysqlAdapter
      def create_table_with_innodb_row_format(table_name, options = {})
        table_options = options.reverse_merge(options: 'ENGINE=InnoDB ROW_FORMAT=DYNAMIC')
        create_table_without_innodb_row_format(table_name, table_options) do |td|
          yield td if block_given?
        end
      end

      alias_method_chain :create_table, :innodb_row_format
    end
  end
end
