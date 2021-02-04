import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram/helpers/helpers.dart';
import 'package:flutter_instagram/models/models.dart';
import 'package:flutter_instagram/repositories/repositories.dart';
import 'package:flutter_instagram/screens/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:flutter_instagram/screens/profile/bloc/profile_bloc.dart';
import 'package:flutter_instagram/widgets/widgets.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfileScreenArgs {
  final BuildContext context;

  const EditProfileScreenArgs({@required this.context});
}

class EditProfileScreen extends StatelessWidget {
  static const String routeName = '/editProfile';

  static Route route({@required EditProfileScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<EditProfileCubit>(
        create: (_) => EditProfileCubit(
          userRepository: context.read<UserRepository>(),
          storageRepository: context.read<StorageRepository>(),
          profileBloc: args.context.read<ProfileBloc>(),
        ),
        child: EditProfileScreen(
            user: args.context.read<ProfileBloc>().state.user),
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final User user;

  EditProfileScreen({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
        ),
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            if (state.status == EditProfileStatus.success) {
              Navigator.of(context).pop();
            } else if (state.status == EditProfileStatus.error) {
              showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(content: state.failure.message),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (state.status == EditProfileStatus.submitting)
                    const LinearProgressIndicator(),
                  const SizedBox(height: 32.0),
                  GestureDetector(
                    onTap: () => _selectProfileImage(context),
                    child: UserProfileImage(
                      radius: 80.0,
                      profileImageUrl: user.profileImageUrl,
                      profileImage: state.profileImage,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            initialValue: user.username,
                            decoration: InputDecoration(hintText: 'Username'),
                            onChanged: (value) => context
                                .read<EditProfileCubit>()
                                .usernameChanged(value),
                            validator: (value) => value.trim().isEmpty
                                ? 'Username cannot be empty.'
                                : null,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            initialValue: user.bio,
                            decoration: InputDecoration(hintText: 'Bio'),
                            onChanged: (value) => context
                                .read<EditProfileCubit>()
                                .bioChanged(value),
                            validator: (value) => value.trim().isEmpty
                                ? 'Bio cannot be empty.'
                                : null,
                          ),
                          const SizedBox(height: 28.0),
                          RaisedButton(
                            elevation: 1.0,
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            onPressed: () => _submitForm(
                              context,
                              state.status == EditProfileStatus.submitting,
                            ),
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectProfileImage(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.circle,
      title: 'Profile Image',
    );
    if (pickedFile != null) {
      context.read<EditProfileCubit>().profileImageChanged(pickedFile);
    }
  }

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_formKey.currentState.validate() && !isSubmitting) {
      context.read<EditProfileCubit>().submit();
    }
  }
}
