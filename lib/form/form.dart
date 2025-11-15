// TYPES START

enum FormElementType {
  text('string'),
  checkbox('boolean'),
  date('string', format: 'date'),
  dateTime('string', format: 'date-time'),
  select('string');

  const FormElementType(this.value, {this.format});

  final String value;
  final String? format;
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
      'type': type.value,
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
}

class SelectFormElementOption {
  String value;

  SelectFormElementOption({
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }

  factory SelectFormElementOption.fromJson(Map<String, dynamic> json) {
    return SelectFormElementOption(
      value: json['value'].toString(),
    );
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
        .map((option) => {
              'const': option.toJson(),
              'type': 'string',
              'title': option.value,
            })
        .toList();
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
      //todo: saving title and desc on MCA backend so no need to save here
      // if (title != null && title!.isNotEmpty) 'title': title,
      // if (description != null && description!.isNotEmpty)
      // 'description': description,
      'type': 'object',
      'required': requiredFields.map((e) => e.label).toList(),
      'properties': {
        for (var element in elements) element.field: element.toJson(),
      }
    };
  }
}

// FORM SCHEMA END
