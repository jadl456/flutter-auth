import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/src/localizations/supa_email_auth_localization.dart';
import 'package:supabase_auth_ui/src/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// {@template metadata_field}
/// Information about the metadata to pass to the signup form
///
/// You can use this object to create additional text fields that will be
/// passed to the metadata of the user upon signup.
/// For example, in order to create additional `username` field, you can use the following:
/// ```dart
/// MetaDataField(label: 'Username', key: 'username')
/// ```
///
/// Which will update the user's metadata in like the following:
///
/// ```dart
/// { 'username': 'Whatever your user entered' }
/// ```
/// {@endtemplate}
class MetaDataField {
  /// Label of the `TextFormField` for this metadata
  final String label;

  /// Key to be used when sending the metadata to Supabase
  final String key;

  /// Validator function for the metadata field
  final String? Function(String?)? validator;

  /// Icon to show as the prefix icon in TextFormField
  final Icon? prefixIcon;

  /// {@macro metadata_field}
  MetaDataField({
    required this.label,
    required this.key,
    this.validator,
    this.prefixIcon,
  });
}

/// {@template selection_metadata_field}
/// Represents a selection field for the signup form.
///
/// This class is used to create fields that allow selecting a value from a list of options.
/// The selected value will be passed to the metadata of the user upon signup.
///
/// For example, to create a field for selecting a language:
/// ```dart
/// SelectionMetaDataField(
///   label: 'Language',
///   key: 'language',
///   options: ['English', 'Spanish', 'French'],
///   defaultButtonText: 'Select a language',
/// )
/// ```
///
/// Which will update the user's metadata accordingly:
///
/// ```dart
/// { 'language': 'Spanish' }
/// ```
///
/// You can also provide custom display and value options:
/// ```dart
/// SelectionMetaDataField(
///   label: 'Language',
///   key: 'language',
///   options: [
///     SelectionOption(display: 'English', value: 'en'),
///     SelectionOption(display: 'Spanish', value: 'es'),
///     SelectionOption(display: 'French', value: 'fr'),
///   ],
///   defaultButtonText: 'Select a language',
/// )
/// ```
/// {@endtemplate}
class SelectionMetaDataField extends MetaDataField {
  /// The list of options to select from
  final List<dynamic> options;

  /// The text to display on the button when no option is selected
  final String defaultButtonText;

  /// Custom builder for the modal that shows the options
  final Widget Function(BuildContext context, Function(dynamic) onSelect)?
      modalBuilder;

  /// Custom builder for displaying the selected option
  final String Function(dynamic)? displayBuilder;

  /// Custom builder for the value to store in metadata
  final String Function(dynamic)? valueBuilder;

  /// {@macro selection_metadata_field}
  SelectionMetaDataField({
    required super.label,
    required super.key,
    required this.options,
    required this.defaultButtonText,
    super.prefixIcon,
    super.validator,
    this.modalBuilder,
    this.displayBuilder,
    this.valueBuilder,
  });

  /// Get the display text for an option
  String getDisplayText(dynamic option) {
    if (displayBuilder != null) {
      return displayBuilder!(option);
    }

    if (option is SelectionOption) {
      return option.display;
    }

    return option.toString();
  }

  /// Get the value for an option
  String getValue(dynamic option) {
    if (valueBuilder != null) {
      return valueBuilder!(option);
    }

    if (option is SelectionOption) {
      return option.value;
    }

    return option.toString();
  }
}

/// Represents an option for SelectionMetaDataField
class SelectionOption {
  /// The text to display for this option
  final String display;

  /// The value to store in metadata when this option is selected
  final String value;

  /// Creates a new SelectionOption
  const SelectionOption({
    required this.display,
    required this.value,
  });
}

/// {@template boolean_metadata_field}
/// Represents a boolean metadata field for the signup form.
///
/// This class is used to create checkbox fields that will be passed
/// to the metadata of the user upon signup. It supports both simple
/// text labels and rich text labels with interactive elements.
///
/// For example, in order to add a simple consent checkbox,
/// you can use the following:
/// ```dart
/// BooleanMetaDataField(
///   label: 'I agree to marketing emails',
///   key: 'email_consent',
/// )
/// ```
///
/// Which will update the user's metadata accordingly:
///
/// ```dart
/// { 'email_consent': true }
/// ```
///
/// You can also use rich text labels with interactive elements.
/// For example:
/// ```dart
/// BooleanMetaDataField(
///   key: 'terms_and_conditions_consent',
///   required: true,
///   richLabelSpans: [
///     TextSpan(text: 'I have read and agree to the '),
///     TextSpan(
///       text: 'Terms and Conditions',
///       style: TextStyle(color: Colors.blue),
///       recognizer: TapGestureRecognizer()
///         ..onTap = () {
///           // Handle tap on 'Terms and Conditions'
///         },
///     ),
///   ],
/// )
/// ```
///
/// This will create a checkbox with a label that includes a link to the terms
/// and conditions. When the user taps on the link, you can handle the tap
/// event in your application. Because `required` is set to `true`, the user
/// must check the checkbox in order to sign up.
/// {@endtemplate}
class BooleanMetaDataField extends MetaDataField {
  /// Whether the checkbox is initially checked.
  final bool value;

  /// Rich text spans for the label. If provided, this will be used instead of [label].
  final List<InlineSpan>? richLabelSpans;

  /// Position of the checkbox in the [ListTile] created by this.
  ///
  /// Default is to ListTileControlAffinity.platform, which matches the default
  /// value of the underlying ListTile widget.
  final ListTileControlAffinity checkboxPosition;

  /// Whether the field is required.
  ///
  /// If true, the user must check the checkbox in order for the form to submit.
  final bool isRequired;

  /// Semantic label for the checkbox.
  final String? checkboxSemanticLabel;

  /// {@macro boolean_metadata_field}
  BooleanMetaDataField({
    String? label,
    this.value = false,
    this.richLabelSpans,
    this.checkboxSemanticLabel,
    this.isRequired = false,
    this.checkboxPosition = ListTileControlAffinity.platform,
    required super.key,
  })  : assert(label != null || richLabelSpans != null,
            'Either label or richLabelSpans must be provided'),
        super(label: label ?? '');

  Widget getLabelWidget(BuildContext context) {
    // This matches the default style of [TextField], to match the other fields
    // in the form. TextField's default style uses `bodyLarge` for Material 3,
    // or otherwise `titleMedium`.
    final defaultStyle = Theme.of(context).useMaterial3
        ? Theme.of(context).textTheme.bodyLarge
        : Theme.of(context).textTheme.titleMedium;
    return richLabelSpans != null
        ? RichText(
            text: TextSpan(
              style: defaultStyle,
              children: richLabelSpans,
            ),
          )
        : Text(label, style: defaultStyle);
  }
}

// Used to allow storing both bool and TextEditingController in the same map.
typedef MetadataController = Object;

/// {@template supa_email_auth}
/// UI component to create email and password signup/ signin form
///
/// ```dart
/// SupaEmailAuth(
///   onSignInComplete: (response) {
///     // handle sign in complete here
///   },
///   onSignUpComplete: (response) {
///     // handle sign up complete here
///   },
/// ),
/// ```
/// {@endtemplate}
class SupaEmailAuth extends StatefulWidget {
  /// The URL to redirect the user to when clicking on the link on the
  /// confirmation link after signing up.
  final String? redirectTo;

  /// The URL to redirect the user to when clicking on the link on the
  /// password recovery link.
  ///
  /// If unspecified, the [redirectTo] value will be used.
  final String? resetPasswordRedirectTo;

  /// Validator function for the password field
  ///
  /// If null, a default validator will be used that checks if
  /// the password is at least 6 characters long.
  final String? Function(String?)? passwordValidator;

  /// Callback for the user to complete a sign in.
  final void Function(AuthResponse response) onSignInComplete;

  /// Callback for the user to complete a signUp.
  ///
  /// If email confirmation is turned on, the user is
  final void Function(AuthResponse response) onSignUpComplete;

  /// Callback for sending the password reset email
  final void Function()? onPasswordResetEmailSent;

  /// Callback for when the auth action threw an exception
  ///
  /// If set to `null`, a snack bar with error color will show up.
  final void Function(Object error)? onError;

  /// Callback for toggling between sign in and sign up
  final void Function(bool isSigningIn)? onToggleSignIn;

  /// Callback for toggling between sign-in/ sign-up and password recovery
  final void Function(bool isRecoveringPassword)? onToggleRecoverPassword;

  /// Set of additional fields to the signup form that will become
  /// part of the user_metadata
  final List<MetaDataField>? metadataFields;

  /// Additional properties for user_metadata on signup
  final Map<String, dynamic>? extraMetadata;

  /// Localization for the form
  final SupaEmailAuthLocalization localization;

  /// Whether the form should display sign-in or sign-up initially
  final bool isInitiallySigningIn;

  /// Icons or custom prefix widgets for email UI
  final Widget? prefixIconEmail;
  final Widget? prefixIconPassword;
  final Widget? suffixIconPassword;

  /// Icon or custom prefix widget for OTP input field
  final Widget? prefixIconOtp;

  /// Whether the confirm password field should be displayed
  final bool showConfirmPasswordField;

  /// Whether to use OTP for password recovery instead of magic link
  final bool useOtpForPasswordRecovery;

  /// {@macro supa_email_auth}
  const SupaEmailAuth({
    super.key,
    this.redirectTo,
    this.resetPasswordRedirectTo,
    this.passwordValidator,
    required this.onSignInComplete,
    required this.onSignUpComplete,
    this.onPasswordResetEmailSent,
    this.onError,
    this.onToggleSignIn,
    this.onToggleRecoverPassword,
    this.metadataFields,
    this.extraMetadata,
    this.localization = const SupaEmailAuthLocalization(),
    this.isInitiallySigningIn = true,
    this.prefixIconEmail = const Icon(Icons.email),
    this.prefixIconPassword = const Icon(Icons.lock),
    this.suffixIconPassword = const Icon(Icons.visibility_off),
    this.prefixIconOtp = const Icon(Icons.security),
    this.showConfirmPasswordField = false,
    this.useOtpForPasswordRecovery = false,
  });

  @override
  State<SupaEmailAuth> createState() => _SupaEmailAuthState();
}

class _SupaEmailAuthState extends State<SupaEmailAuth> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late bool _isSigningIn;
  late final Map<String, MetadataController> _metadataControllers;

  // Map to store selected values for SelectionMetaDataField
  final Map<String, String?> _selectionValues = {};

  bool _isLoading = false;

  /// The user has pressed forgot password button
  bool _isRecoveringPassword = false;

  /// Focus node for email field
  final FocusNode _emailFocusNode = FocusNode();

  /// Controller for OTP input field
  final _otpController = TextEditingController();

  /// Controller for new password input field
  final _newPasswordController = TextEditingController();

  /// Controller for confirm new password input field
  final _confirmNewPasswordController = TextEditingController();

  /// Whether the user is entering OTP code
  bool _isEnteringOtp = false;

  /// Password visibility state for all password fields
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _isSigningIn = widget.isInitiallySigningIn;
    _metadataControllers = Map.fromEntries((widget.metadataFields ?? []).map(
      (metadataField) => MapEntry(
        metadataField.key,
        metadataField is BooleanMetaDataField
            ? metadataField.value
            : TextEditingController(),
      ),
    ));

    // Initialize selection values
    for (final field in widget.metadataFields ?? []) {
      if (field is SelectionMetaDataField) {
        _selectionValues[field.key] = null;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    for (final controller in _metadataControllers.values) {
      if (controller is TextEditingController) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = widget.localization;
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autofocus: false,
              focusNode: _emailFocusNode,
              textInputAction: _isRecoveringPassword
                  ? TextInputAction.done
                  : TextInputAction.next,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !EmailValidator.validate(_emailController.text)) {
                  return localization.validEmailError;
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: widget.prefixIconEmail,
                label: Text(localization.enterEmail),
              ),
              controller: _emailController,
              onFieldSubmitted: (_) {
                if (_isRecoveringPassword) {
                  _passwordRecovery();
                }
              },
            ),
            if (!_isRecoveringPassword) ...[
              spacer(16),
              TextFormField(
                autofillHints: _isSigningIn
                    ? [AutofillHints.password]
                    : [AutofillHints.newPassword],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: widget.metadataFields != null && !_isSigningIn
                    ? TextInputAction.next
                    : TextInputAction.done,
                validator: widget.passwordValidator ??
                    (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return localization.passwordLengthError;
                      }
                      return null;
                    },
                decoration: InputDecoration(
                  prefixIcon: widget.prefixIconPassword,
                  label: Text(localization.enterPassword),
                  suffixIcon: IconButton(
                    icon: widget.suffixIconPassword ??
                        Icon(_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
                controller: _passwordController,
                onFieldSubmitted: (_) {
                  if (widget.metadataFields == null || _isSigningIn) {
                    _signInSignUp();
                  }
                },
              ),
              if (widget.showConfirmPasswordField && !_isSigningIn) ...[
                spacer(16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    prefixIcon: widget.prefixIconPassword,
                    label: Text(localization.confirmPassword),
                    suffixIcon: IconButton(
                      icon: widget.suffixIconPassword ??
                          Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return localization.confirmPasswordError;
                    }
                    return null;
                  },
                ),
              ],
              spacer(16),
              if (widget.metadataFields != null && !_isSigningIn)
                ...widget.metadataFields!
                    .map((metadataField) => [
                          // Render a Checkbox that displays an error message
                          // beneath it if the field is required and the user
                          // hasn't checked it when submitting the form.
                          if (metadataField is BooleanMetaDataField)
                            FormField<bool>(
                              validator: metadataField.isRequired
                                  ? (bool? value) {
                                      if (value != true) {
                                        return localization.requiredFieldError;
                                      }
                                      return null;
                                    }
                                  : null,
                              builder: (FormFieldState<bool> field) {
                                final theme = Theme.of(context);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CheckboxListTile(
                                      title:
                                          metadataField.getLabelWidget(context),
                                      value: _metadataControllers[
                                          metadataField.key] as bool,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _metadataControllers[metadataField
                                              .key] = value ?? false;
                                        });
                                        field.didChange(value);
                                      },
                                      checkboxSemanticLabel:
                                          metadataField.checkboxSemanticLabel,
                                      controlAffinity:
                                          metadataField.checkboxPosition,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                    ),
                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, top: 4),
                                        child: Text(
                                          field.errorText!,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            )
                          else if (metadataField is SelectionMetaDataField)
                            // Render a selection field
                            FormField<String>(
                              initialValue: _selectionValues[metadataField.key],
                              validator: (value) {
                                if (metadataField.validator != null) {
                                  return metadataField.validator!(value);
                                }
                                return null;
                              },
                              builder: (FormFieldState<String> field) {
                                final theme = Theme.of(context);
                                final selectedValue =
                                    _selectionValues[metadataField.key];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: selectedValue == null
                                            ? null
                                            : metadataField.label,
                                        prefixIcon: metadataField.prefixIcon,
                                        border: const OutlineInputBorder(),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 12.0),
                                        isDense: true,
                                      ),
                                      isEmpty: selectedValue == null,
                                      child: InkWell(
                                        onTap: () async {
                                          if (metadataField.modalBuilder !=
                                              null) {
                                            // Use custom modal builder
                                            final modalWidget =
                                                metadataField.modalBuilder!(
                                              context,
                                              (selectedOption) {
                                                // Just update the state with the selected value
                                                // Don't call Navigator.pop here as the custom picker
                                                // will handle its own navigation
                                                setState(() {
                                                  final value = metadataField
                                                      .getValue(selectedOption);
                                                  _selectionValues[metadataField
                                                      .key] = value;
                                                  field.didChange(value);
                                                });
                                              },
                                            );

                                            // Only show modal if widget is not empty
                                            if (modalWidget is! SizedBox) {
                                              await showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (context) =>
                                                    modalWidget,
                                              );
                                            }
                                          } else {
                                            // Use default modal
                                            await showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return DraggableScrollableSheet(
                                                  initialChildSize: 0.5,
                                                  maxChildSize: 0.9,
                                                  minChildSize: 0.3,
                                                  expand: false,
                                                  builder: (context,
                                                      scrollController) {
                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16.0),
                                                          child: Text(
                                                            metadataField.label,
                                                            style: theme
                                                                .textTheme
                                                                .titleLarge,
                                                          ),
                                                        ),
                                                        Divider(),
                                                        Expanded(
                                                          child:
                                                              ListView.builder(
                                                            controller:
                                                                scrollController,
                                                            itemCount:
                                                                metadataField
                                                                    .options
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final option =
                                                                  metadataField
                                                                          .options[
                                                                      index];
                                                              final displayText =
                                                                  metadataField
                                                                      .getDisplayText(
                                                                          option);

                                                              return ListTile(
                                                                title: Text(
                                                                    displayText),
                                                                onTap: () {
                                                                  setState(() {
                                                                    final value =
                                                                        metadataField
                                                                            .getValue(option);
                                                                    _selectionValues[
                                                                        metadataField
                                                                            .key] = value;
                                                                    field.didChange(
                                                                        value);
                                                                  });
                                                                  // Close the default modal
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  selectedValue != null
                                                      ? metadataField.options
                                                          .where((option) =>
                                                              metadataField
                                                                  .getValue(
                                                                      option) ==
                                                              selectedValue)
                                                          .map((option) =>
                                                              metadataField
                                                                  .getDisplayText(
                                                                      option))
                                                          .firstWhere(
                                                              (_) => true,
                                                              orElse: () =>
                                                                  selectedValue)
                                                      : metadataField
                                                          .defaultButtonText,
                                                  style: selectedValue == null
                                                      ? TextStyle(
                                                          color:
                                                              theme.hintColor)
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .titleMedium,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, top: 4),
                                        child: Text(
                                          field.errorText!,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            )
                          else
                            // Otherwise render a normal TextFormField matching
                            // the style of the other fields in the form.
                            TextFormField(
                              controller:
                                  _metadataControllers[metadataField.key]
                                      as TextEditingController,
                              textInputAction:
                                  widget.metadataFields!.last == metadataField
                                      ? TextInputAction.done
                                      : TextInputAction.next,
                              decoration: InputDecoration(
                                label: Text(metadataField.label),
                                prefixIcon: metadataField.prefixIcon,
                              ),
                              validator: metadataField.validator,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onFieldSubmitted: (_) {
                                if (metadataField !=
                                    widget.metadataFields!.last) {
                                  FocusScope.of(context).nextFocus();
                                } else {
                                  _signInSignUp();
                                }
                              },
                            ),
                          spacer(16),
                        ])
                    .expand((element) => element),
              ElevatedButton(
                onPressed: _signInSignUp,
                child: (_isLoading)
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 1.5,
                        ),
                      )
                    : Text(_isSigningIn
                        ? localization.signIn
                        : localization.signUp),
              ),
              spacer(16),
              if (_isSigningIn) ...[
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRecoveringPassword = true;
                    });
                    widget.onToggleRecoverPassword?.call(_isRecoveringPassword);
                  },
                  child: Text(localization.forgotPassword),
                ),
              ],
              TextButton(
                key: const ValueKey('toggleSignInButton'),
                onPressed: () {
                  setState(() {
                    _isRecoveringPassword = false;
                    _isSigningIn = !_isSigningIn;
                  });
                  widget.onToggleSignIn?.call(_isSigningIn);
                  widget.onToggleRecoverPassword?.call(_isRecoveringPassword);
                },
                child: Text(_isSigningIn
                    ? localization.dontHaveAccount
                    : localization.haveAccount),
              ),
            ],
            if (_isSigningIn && _isRecoveringPassword) ...[
              spacer(16),
              if (!_isEnteringOtp) ...[
                ElevatedButton(
                  onPressed: _passwordRecovery,
                  child: Text(localization.sendPasswordReset),
                ),
              ] else ...[
                TextFormField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    label: Text(localization.enterOtpCode),
                    prefixIcon: widget.prefixIconOtp,
                  ),
                  keyboardType: TextInputType.number,
                ),
                spacer(16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    label: Text(localization.enterNewPassword),
                    prefixIcon: widget.prefixIconPassword,
                    suffixIcon: IconButton(
                      icon: widget.suffixIconPassword ??
                          Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: widget.passwordValidator ??
                      (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 6) {
                          return localization.passwordLengthError;
                        }
                        return null;
                      },
                ),
                spacer(16),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  decoration: InputDecoration(
                    label: Text(localization.confirmPassword),
                    prefixIcon: widget.prefixIconPassword,
                    suffixIcon: IconButton(
                      icon: widget.suffixIconPassword ??
                          Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return localization.confirmPasswordError;
                    }
                    return null;
                  },
                ),
                spacer(16),
                ElevatedButton(
                  onPressed: _verifyOtpAndResetPassword,
                  child: Text(localization.changePassword),
                ),
              ],
              spacer(16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRecoveringPassword = false;
                  });
                },
                child: Text(localization.backToSignIn),
              ),
            ],
            spacer(16),
          ],
        ),
      ),
    );
  }

  void _signInSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isSigningIn) {
        final response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        widget.onSignInComplete.call(response);
      } else {
        final user = supabase.auth.currentUser;
        late final AuthResponse response;
        if (user?.isAnonymous == true) {
          await supabase.auth.updateUser(
            UserAttributes(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              data: _resolveData(),
            ),
            emailRedirectTo: widget.redirectTo,
          );
          final newSession = supabase.auth.currentSession;
          response = AuthResponse(session: newSession);
        } else {
          response = await supabase.auth.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            emailRedirectTo: widget.redirectTo,
            data: _resolveData(),
          );
        }
        widget.onSignUpComplete.call(response);
      }
    } on AuthException catch (error) {
      if (widget.onError == null && mounted) {
        context.showErrorSnackBar(error.message);
      } else {
        widget.onError?.call(error);
      }
      _emailFocusNode.requestFocus();
    } catch (error) {
      if (widget.onError == null && mounted) {
        context.showErrorSnackBar(
            '${widget.localization.unexpectedError}: $error');
      } else {
        widget.onError?.call(error);
      }
      _emailFocusNode.requestFocus();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _passwordRecovery() async {
    try {
      if (!_formKey.currentState!.validate()) {
        // Focus on email field if validation fails
        _emailFocusNode.requestFocus();
        return;
      }
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();

      if (widget.useOtpForPasswordRecovery) {
        await supabase.auth.resetPasswordForEmail(
          email,
          redirectTo: widget.resetPasswordRedirectTo ?? widget.redirectTo,
        );
        if (!mounted) return;
        context.showSnackBar(widget.localization.passwordResetSent);
        setState(() {
          _isEnteringOtp = true;
        });
      } else {
        await supabase.auth.resetPasswordForEmail(
          email,
          redirectTo: widget.resetPasswordRedirectTo ?? widget.redirectTo,
        );
        widget.onPasswordResetEmailSent?.call();
        if (!mounted) return;
        context.showSnackBar(widget.localization.passwordResetSent);
        setState(() {
          _isRecoveringPassword = false;
        });
      }
    } on AuthException catch (error) {
      widget.onError?.call(error);
    } catch (error) {
      widget.onError?.call(error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _verifyOtpAndResetPassword() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await supabase.auth.verifyOTP(
          type: OtpType.recovery,
          email: _emailController.text.trim(),
          token: _otpController.text.trim(),
        );
      } on AuthException catch (error) {
        if (error.code == 'otp_expired') {
          if (!mounted) return;
          context.showErrorSnackBar(widget.localization.otpCodeError);
          return;
        } else if (error.code == 'otp_disabled') {
          if (!mounted) return;
          context.showErrorSnackBar(widget.localization.otpDisabledError);
          return;
        }
        rethrow;
      }

      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (!mounted) return;
      context.showSnackBar(widget.localization.passwordChangedSuccess);
      setState(() {
        _isRecoveringPassword = false;
        _isEnteringOtp = false;
      });
    } on AuthException catch (error) {
      widget.onError?.call(error);
    } catch (error) {
      widget.onError?.call(error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Resolve the user_metadata that we will send during sign-up
  ///
  /// In case both MetadataFields and extraMetadata have the same
  /// key in their map, the MetadataFields (form fields) win
  Map<String, dynamic> _resolveData() {
    var extra = widget.extraMetadata ?? <String, dynamic>{};
    extra.addAll(_resolveMetadataFieldsData());
    return extra;
  }

  /// Resolve the user_metadata coming from the metadataFields
  Map<String, dynamic> _resolveMetadataFieldsData() {
    final result = <String, dynamic>{};

    // Add text field values
    for (final entry in _metadataControllers.entries) {
      if (entry.value is TextEditingController) {
        result[entry.key] = (entry.value as TextEditingController).text;
      } else {
        result[entry.key] = entry.value;
      }
    }

    // Add selection field values
    for (final entry in _selectionValues.entries) {
      if (entry.value != null) {
        result[entry.key] = entry.value;
      }
    }

    return result;
  }
}
