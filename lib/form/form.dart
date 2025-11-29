// TYPES START

import 'dart:convert';

import 'package:cross_file/cross_file.dart';

enum FormElementType {
  text('string', value: 'text_field', label: 'Text'),
  checkbox('boolean', value: 'checkbox_field', label: 'Checkbox'),
  date('string', value: 'date_field', label: 'Date', format: 'date'),
  dateTime(
    'string',
    value: 'date_time_field',
    label: 'Date & Time',
    format: 'date-time',
  ),
  select('string', value: 'select_field', label: 'Dropdown'),
  file('string', value: 'file_field', label: 'File Upload', format: 'data-url');

  const FormElementType(
    this.type, {
    required this.value,
    required this.label,
    this.format,
  });

  final String type;
  final String value;
  final String label;
  final String? format;

  Map<String, dynamic> toJson() {
    return {
      'type': value,
      'label': label,
      if (format != null) 'format': format,
    };
  }
}

abstract class FormElement<T> {
  String field;
  String label;
  bool isRequired;
  T? initialValue;

  FormElement({
    this.field = '',
    this.label = '',
    this.isRequired = false,
    this.initialValue,
  });

  FormElementType get type;

  bool get isValid;

  bool get isText => type == FormElementType.text;
  bool get isCheckbox => type == FormElementType.checkbox;
  bool get isDate => type == FormElementType.date;
  bool get isDateTime => type == FormElementType.dateTime;
  bool get isSelect => type == FormElementType.select;

  Map<String, dynamic> toJson() {
    return {
      'type': type.type,
      'type_value': type.value,
      'title': label,
      'required': isRequired,
      if (type.format != null) 'format': type.format,
      if (initialValue != null) 'default': initialValue.toString(),
    };
  }
}

class TextFormElement extends FormElement<String> {
  @override
  FormElementType get type => FormElementType.text;

  @override
  bool get isValid =>
      isRequired ? (initialValue != null && initialValue!.isNotEmpty) : true;

  TextFormElement({
    super.field,
    super.label,
    super.isRequired,
    super.initialValue,
  });

  factory TextFormElement.fromJson(Map json) {
    return TextFormElement(
      field: json['title']?.toString() ?? '',
      label: json['title']?.toString() ?? '',
      isRequired: json['required'] as bool? ?? false,
      initialValue: json['default']?.toString(),
    );
  }
}

class CheckboxFormElement extends FormElement<bool> {
  @override
  FormElementType get type => FormElementType.checkbox;

  @override
  bool get isValid =>
      isRequired ? (initialValue != null && initialValue!) : true;

  CheckboxFormElement({
    super.field,
    super.label,
    super.isRequired,
    super.initialValue,
  });

  factory CheckboxFormElement.fromJson(Map json) {
    return CheckboxFormElement(
      field: json['title']?.toString() ?? '',
      label: json['title']?.toString() ?? '',
      isRequired: json['required'] as bool? ?? false,
      initialValue: bool.tryParse(json['default']?.toString() ?? ''),
    );
  }
}

class DateFormElement extends FormElement<DateTime> {
  @override
  FormElementType get type =>
      includeTime ? FormElementType.dateTime : FormElementType.date;

  @override
  bool get isValid => isRequired ? (initialValue != null) : true;

  final bool includeTime;

  DateFormElement({
    super.field,
    super.label,
    super.isRequired,
    super.initialValue,
    this.includeTime = false,
  });

  factory DateFormElement.fromJson(Map json) {
    return DateFormElement(
      field: json['title']?.toString() ?? '',
      label: json['title']?.toString() ?? '',
      isRequired: json['required'] as bool? ?? false,
      initialValue: DateTime.tryParse(json['default']?.toString() ?? ''),
      includeTime: (json['format']?.toString() ?? '') == 'date-time',
    );
  }
}

class SelectFormElementOption {
  String value;

  SelectFormElementOption({
    required this.value,
  });

  factory SelectFormElementOption.fromJson(Map<String, dynamic> json) {
    return SelectFormElementOption(
      value: json['value'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }

  @override
  String toString() {
    return value;
  }
}

class SelectFormElement extends FormElement<SelectFormElementOption> {
  @override
  FormElementType get type => FormElementType.select;

  @override
  bool get isValid =>
      options.isNotEmpty && (isRequired ? (initialValue != null) : true);

  List<SelectFormElementOption> options;

  SelectFormElement({
    super.field,
    super.label,
    super.isRequired,
    super.initialValue,
    required this.options,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['oneOf'] = options
        .map(
          (option) => {
            'const': option.toJson(),
            'type': 'string',
            'title': option.value,
          },
        )
        .toList();
    return json;
  }

  factory SelectFormElement.fromJson(Map json) {
    final List<SelectFormElementOption> opts = json['oneOf'] != null
        ? (json['oneOf'] as List)
            .map(
              (optionJson) => SelectFormElementOption.fromJson(
                optionJson['const'] as Map<String, dynamic>,
              ),
            )
            .toList()
        : [];
    SelectFormElementOption? initVal;

    try {
      if (json['default'] != null) {
        initVal = opts.firstWhere(
          (option) => option.value == json['default'].toString(),
        );
      }
    } catch (e) {
      // no-op
    }

    return SelectFormElement(
      field: json['title']?.toString() ?? '',
      label: json['title']?.toString() ?? '',
      isRequired: json['required'] as bool? ?? false,
      options: opts,
      initialValue: initVal,
    );
  }
}

class FileFormElement extends FormElement<XFile> {
  @override
  FormElementType get type => FormElementType.file;

  @override
  bool get isValid => isRequired ? (initialValue != null) : true;

  bool allowMultiple;

  FileFormElement({
    super.field,
    super.label,
    super.isRequired,
    super.initialValue,
    this.allowMultiple = false,
  });

  factory FileFormElement.fromJson(Map json) {
    return FileFormElement(
      field: json['title']?.toString() ?? '',
      label: json['title']?.toString() ?? '',
      isRequired: json['required'] as bool? ?? false,
      allowMultiple: json['allowMultiple'] as bool? ?? false,
      initialValue: json['default'] != null
          //todo: this data is not used, just to let json_form understand there is a default value
          ? XFile.fromData(
              base64Decode(json['default'].toString()),
              name: 'Test',
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['allowMultiple'] = allowMultiple;
    if (allowMultiple) {
      json['type'] = 'array';
      json['items'] = {
        'type': type.type,
        'format': type.format,
      };
    }
    print(json);
    return json;
  }
}

// TYPES END

// FORM SCHEMA START

class FormSchema {
  String? title;
  String? description;
  final List<FormElement> elements;

  FormSchema({
    this.title,
    this.description,
  }) : elements = [];

  Iterable<FormElement> get requiredFields => elements.where(
        (element) => element.isRequired,
      );

  Map<String, dynamic> toJson() {
    return {
      if (title != null && title!.isNotEmpty) 'title': title,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'type': 'object',
      'required': requiredFields.map((e) => e.label).toList(),
      'properties': {
        // ignore: prefer_final_in_for_each
        for (var element in elements) element.field: element.toJson(),
      },
    };
  }

  factory FormSchema.fromJson(Map<String, dynamic> json) {
    //{type: object, required: [First Name, Last Name], properties: {Title: {type: string, title: Title, required: false, oneOf: [{const: {value: Mr}, type: string, title: Mr}, {const: {value: Mrs}, type: string, title: Mrs}, {const: {value: Miss}, type: string, title: Miss}, {const: {value: Dr}, type: string, title: Dr}, {const: {value: Prof}, type: string, title: Prof}]}, First Name: {type: string, title: First Name, required: true}, Last Name: {type: string, title: Last Name, required: true}, Birthdate: {type: string, title: Birthdate, required: false, format: date}, Married: {type: boolean, title: Married, required: false}}}
    final sc = FormSchema();
    final elements = <FormElement>[];

    for (final pr in (json['properties']! as Map).entries) {
      //todo: add new form elements here
      switch (pr.value['type_value']) {
        case 'text_field':
          elements.add(TextFormElement.fromJson(pr.value as Map));
          break;
        case 'checkbox_field':
          elements.add(CheckboxFormElement.fromJson(pr.value as Map));
          break;
        case 'date_field':
          elements.add(DateFormElement.fromJson(pr.value as Map));
          break;
        case 'date_time_field':
          elements.add(DateFormElement.fromJson(pr.value as Map));
          break;
        case 'select_field':
          elements.add(SelectFormElement.fromJson(pr.value as Map));
          break;
        case 'file_field':
          elements.add(FileFormElement.fromJson(pr.value as Map));
          break;
        default:
          // no-op
          break;
      }
    }
    sc.elements.addAll(elements);
    return sc;
  }
}

// FORM SCHEMA END
