part of 'generated.dart';

class CreateDailyEntryVariablesBuilder {
  String userId;
  DateTime entryDate;
  Optional<String> _mood = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _notes = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateDailyEntryVariablesBuilder mood(String? t) {
   _mood.value = t;
   return this;
  }
  CreateDailyEntryVariablesBuilder notes(String? t) {
   _notes.value = t;
   return this;
  }

  CreateDailyEntryVariablesBuilder(this._dataConnect, {required  this.userId,required  this.entryDate,});
  Deserializer<CreateDailyEntryData> dataDeserializer = (dynamic json)  => CreateDailyEntryData.fromJson(jsonDecode(json));
  Serializer<CreateDailyEntryVariables> varsSerializer = (CreateDailyEntryVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateDailyEntryData, CreateDailyEntryVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateDailyEntryData, CreateDailyEntryVariables> ref() {
    CreateDailyEntryVariables vars= CreateDailyEntryVariables(userId: userId,entryDate: entryDate,mood: _mood,notes: _notes,);
    return _dataConnect.mutation("CreateDailyEntry", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateDailyEntryDailyEntryInsert {
  final String id;
  CreateDailyEntryDailyEntryInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateDailyEntryDailyEntryInsert otherTyped = other as CreateDailyEntryDailyEntryInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateDailyEntryDailyEntryInsert({
    required this.id,
  });
}

@immutable
class CreateDailyEntryData {
  final CreateDailyEntryDailyEntryInsert dailyEntry_insert;
  CreateDailyEntryData.fromJson(dynamic json):
  
  dailyEntry_insert = CreateDailyEntryDailyEntryInsert.fromJson(json['dailyEntry_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateDailyEntryData otherTyped = other as CreateDailyEntryData;
    return dailyEntry_insert == otherTyped.dailyEntry_insert;
    
  }
  @override
  int get hashCode => dailyEntry_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['dailyEntry_insert'] = dailyEntry_insert.toJson();
    return json;
  }

  CreateDailyEntryData({
    required this.dailyEntry_insert,
  });
}

@immutable
class CreateDailyEntryVariables {
  final String userId;
  final DateTime entryDate;
  late final Optional<String>mood;
  late final Optional<String>notes;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateDailyEntryVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  entryDate = nativeFromJson<DateTime>(json['entryDate']) {
  
  
  
  
    mood = Optional.optional(nativeFromJson, nativeToJson);
    mood.value = json['mood'] == null ? null : nativeFromJson<String>(json['mood']);
  
  
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

    final CreateDailyEntryVariables otherTyped = other as CreateDailyEntryVariables;
    return userId == otherTyped.userId && 
    entryDate == otherTyped.entryDate && 
    mood == otherTyped.mood && 
    notes == otherTyped.notes;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, entryDate.hashCode, mood.hashCode, notes.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['entryDate'] = nativeToJson<DateTime>(entryDate);
    if(mood.state == OptionalState.set) {
      json['mood'] = mood.toJson();
    }
    if(notes.state == OptionalState.set) {
      json['notes'] = notes.toJson();
    }
    return json;
  }

  CreateDailyEntryVariables({
    required this.userId,
    required this.entryDate,
    required this.mood,
    required this.notes,
  });
}

