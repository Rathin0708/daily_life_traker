part of 'generated.dart';

class AddActivityLogVariablesBuilder {
  String activityTypeId;
  String dailyEntryId;
  Timestamp createdAt;
  Optional<String> _notes = Optional.optional(nativeFromJson, nativeToJson);
  int quantity;

  final FirebaseDataConnect _dataConnect;  AddActivityLogVariablesBuilder notes(String? t) {
   _notes.value = t;
   return this;
  }

  AddActivityLogVariablesBuilder(this._dataConnect, {required  this.activityTypeId,required  this.dailyEntryId,required  this.createdAt,required  this.quantity,});
  Deserializer<AddActivityLogData> dataDeserializer = (dynamic json)  => AddActivityLogData.fromJson(jsonDecode(json));
  Serializer<AddActivityLogVariables> varsSerializer = (AddActivityLogVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddActivityLogData, AddActivityLogVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddActivityLogData, AddActivityLogVariables> ref() {
    AddActivityLogVariables vars= AddActivityLogVariables(activityTypeId: activityTypeId,dailyEntryId: dailyEntryId,createdAt: createdAt,notes: _notes,quantity: quantity,);
    return _dataConnect.mutation("AddActivityLog", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddActivityLogActivityLogInsert {
  final String id;
  AddActivityLogActivityLogInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddActivityLogActivityLogInsert otherTyped = other as AddActivityLogActivityLogInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddActivityLogActivityLogInsert({
    required this.id,
  });
}

@immutable
class AddActivityLogData {
  final AddActivityLogActivityLogInsert activityLog_insert;
  AddActivityLogData.fromJson(dynamic json):
  
  activityLog_insert = AddActivityLogActivityLogInsert.fromJson(json['activityLog_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddActivityLogData otherTyped = other as AddActivityLogData;
    return activityLog_insert == otherTyped.activityLog_insert;
    
  }
  @override
  int get hashCode => activityLog_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['activityLog_insert'] = activityLog_insert.toJson();
    return json;
  }

  AddActivityLogData({
    required this.activityLog_insert,
  });
}

@immutable
class AddActivityLogVariables {
  final String activityTypeId;
  final String dailyEntryId;
  final Timestamp createdAt;
  late final Optional<String>notes;
  final int quantity;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddActivityLogVariables.fromJson(Map<String, dynamic> json):
  
  activityTypeId = nativeFromJson<String>(json['activityTypeId']),
  dailyEntryId = nativeFromJson<String>(json['dailyEntryId']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  quantity = nativeFromJson<int>(json['quantity']) {
  
  
  
  
  
    notes = Optional.optional(nativeFromJson, nativeToJson);
    notes.value = json['notes'] == null ? null : nativeFromJson<String>(json['notes']);
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddActivityLogVariables otherTyped = other as AddActivityLogVariables;
    return activityTypeId == otherTyped.activityTypeId && 
    dailyEntryId == otherTyped.dailyEntryId && 
    createdAt == otherTyped.createdAt && 
    notes == otherTyped.notes && 
    quantity == otherTyped.quantity;
    
  }
  @override
  int get hashCode => Object.hashAll([activityTypeId.hashCode, dailyEntryId.hashCode, createdAt.hashCode, notes.hashCode, quantity.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['activityTypeId'] = nativeToJson<String>(activityTypeId);
    json['dailyEntryId'] = nativeToJson<String>(dailyEntryId);
    json['createdAt'] = createdAt.toJson();
    if(notes.state == OptionalState.set) {
      json['notes'] = notes.toJson();
    }
    json['quantity'] = nativeToJson<int>(quantity);
    return json;
  }

  AddActivityLogVariables({
    required this.activityTypeId,
    required this.dailyEntryId,
    required this.createdAt,
    required this.notes,
    required this.quantity,
  });
}

