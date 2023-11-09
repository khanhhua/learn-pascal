PROGRAM Expense;
USES sysutils;

TYPE
  ExpenseRecord = RECORD
      description: String[128];
      amount: Single;
  END;
  ExpenseRecordItem = RECORD
      item: ExpenseRecord;
      next: ^ExpenseRecordItem;
  END;

CONST
  DB_FILENAME = 'db.dat';

VAR
  dataFile: File of ExpenseRecord;
  recordCount: Integer;
  dataHead: ^ExpenseRecordItem;

PROCEDURE setupStorage;
BEGIN
  IF FileExists(DB_FILENAME) = True THEN
  BEGIN
    writeLn('Opening existing file...');
    assign(dataFile, DB_FILENAME);
    reset(dataFile);
    recordCount := fileSize(dataFile);
  END
  ELSE
  BEGIN
    writeLn('Creating new databse...');
    assign(dataFile, DB_FILENAME);
    rewrite(dataFile);
  END;
  close(dataFile)
END;

PROCEDURE loadStorage;
var
  head: ^ExpenseRecordItem;
  item: ExpenseRecord;
BEGIN
  assign(dataFile, DB_FILENAME);
  reset(dataFile);

  new (dataHead);
  WHILE (not EOF(dataFile)) DO
  BEGIN
    read(dataFile, item);

    new (head);
    dataHead^.item := item;
    head^.next := dataHead;
    dataHead := head;
  END
END;

PROCEDURE writeStorage;
var
  current: ^ExpenseRecordItem;
BEGIN
  assign(dataFile, DB_FILENAME);
  rewrite(dataFile);
  current := dataHead^.next;

  WHILE (current <> NIL) DO
  BEGIN
    write('.');
    write(dataFile, current^.item);

    current := current^.next;
  END;
  close(dataFile);
  writeLn(#13#10'Done file outpt.')
END;

PROCEDURE newRecord;
var
  head: ^ExpenseRecordItem;
  item: ExpenseRecord;
BEGIN
  new (head);

  write('Description: ');
  readLn(item.description);
  write('Amount:      ');
  readLn(item.amount);

  dataHead^.item := item;
  head^.next := dataHead;
  dataHead := head;
END;

PROCEDURE showReport;
var
  current: ^ExpenseRecordItem;
  item: ExpenseRecord;
BEGIN
  writeLn('EXPENSE REPORT');
  
  current := dataHead^.next;

  writeLn(format('%-32s%-8s', ['Description', 'Amount']));
  WHILE (current <> NIL) DO
  BEGIN
    item := current^.item;
    writeLn(format('%-32s%8f', [item.description, item.amount]));

    current := current^.next;
  END;
  writeLn('[EOF]')
END;

PROCEDURE main;
var
  choice: char;
BEGIN
  write('(N)ew Entry'#10#13'(R)eport'#10#13'(S)ave'#10#13'Select: ');
  readLn(choice);

  CASE choice OF
    'N': newRecord;
    'R': showReport;
    'S': writeStorage;
  END;
  main;
END;


BEGIN
  setupStorage;
  loadStorage;

  main;
END.
