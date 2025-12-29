library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_daily_entry.dart';

part 'get_daily_entry.dart';

part 'add_activity_log.dart';

part 'list_activity_types.dart';







class ExampleConnector {
  
  
  CreateDailyEntryVariablesBuilder createDailyEntry ({required String userId, required DateTime entryDate, }) {
    return CreateDailyEntryVariablesBuilder(dataConnect, userId: userId,entryDate: entryDate,);
  }
  
  
  GetDailyEntryVariablesBuilder getDailyEntry ({required String id, }) {
    return GetDailyEntryVariablesBuilder(dataConnect, id: id,);
  }
  
  
  AddActivityLogVariablesBuilder addActivityLog ({required String activityTypeId, required String dailyEntryId, required Timestamp createdAt, required int quantity, }) {
    return AddActivityLogVariablesBuilder(dataConnect, activityTypeId: activityTypeId,dailyEntryId: dailyEntryId,createdAt: createdAt,quantity: quantity,);
  }
  
  
  ListActivityTypesVariablesBuilder listActivityTypes () {
    return ListActivityTypesVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'dailyroutinefollowtracker',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
