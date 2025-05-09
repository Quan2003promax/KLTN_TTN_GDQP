object ServerMethods1: TServerMethods1
  OldCreateOrder = False
  Height = 356
  Width = 517
  object ADO1: TADOConnection
    CommandTimeout = 0
    Connected = True
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=khoaluan21;Persist Security Info=Tr' +
      'ue;User ID=KhoaLuan21;Initial Catalog=QLDaoTao_25;Data Source=AN' +
      'HQUAN\ANHQUAN'
    ConnectionTimeout = 0
    Provider = 'SQLOLEDB.1'
    Left = 56
    Top = 24
  end
  object ADODataSet1: TADODataSet
    Connection = ADO1
    CommandTimeout = 0
    Parameters = <>
    Left = 56
    Top = 88
  end
  object DataSetProviderGV: TDataSetProvider
    DataSet = ADODataSet1
    Options = [poAllowCommandText, poUseQuoteChar]
    Left = 56
    Top = 160
  end
  object ADO2: TADOConnection
    CommandTimeout = 0
    Connected = True
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=sinhvien21;Persist Security Info=Tr' +
      'ue;User ID=SinhVien21;Initial Catalog=QLDaoTao_25;Data Source=AN' +
      'HQUAN\ANHQUAN'
    ConnectionTimeout = 0
    Provider = 'SQLOLEDB.1'
    Left = 176
    Top = 24
  end
  object ADODataSet2: TADODataSet
    Connection = ADO2
    CommandTimeout = 0
    Parameters = <>
    Left = 176
    Top = 88
  end
  object DataSetProviderSV: TDataSetProvider
    DataSet = ADODataSet2
    Options = [poAllowCommandText, poUseQuoteChar]
    Left = 176
    Top = 160
  end
end
