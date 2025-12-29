part of 'generated.dart';

class ListActivityTypesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListActivityTypesVariablesBuilder(this._dataConnect, );
  Deserializer<ListActivityTypesData> dataDeserializer = (dynamic json)  => ListActivityTypesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListActivityTypesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListActivityTypesData, void> ref() {
    
    return _dataConnect.query("ListActivityTypes", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListActivityTypesActivityTypes {
  final String id;
  final String name;
  final String? description;
  ListActivityTypesActivityTypes.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListActivityTypesActivityTypes otherTyped = other as ListActivityTypesActivityTypes;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    description == otherTyped.description;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, description.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    return json;
  }

  ListActivityTypesActivityTypes({
    required this.id,
    required this.name,
    this.description,
  });
}

@immutable
class ListActivityTypesData {
  final List<ListActivityTypesActivityTypes> activityTypes;
  ListActivityTypesData.fromJson(dynamic json):
  
  activityTypes = (json['activityTypes'] as List<dynamic>)
        .map((e) => ListActivityTypesActivityTypes.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListActivityTypesData otherTyped = other as ListActivityTypesData;
    return activityTypes == otherTyped.activityTypes;
    
  }
  @override
  int get hashCode => activityTypes.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['activityTypes'] = activityTypes.map((e) => e.toJson()).toList();
    return json;
  }

  ListActivityTypesData({
    required this.activityTypes,
  });
}

