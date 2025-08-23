// lib/utils/registration_error_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:projecho/main/app_theme.dart';
import 'registration_flow_manager.dart';

class RegistrationErrorHandler {
  static const int maxRetries = 3;
  static const Duration baseRetryDelay = Duration(seconds: 2);

  // Show error dialog with retry options
  static Future<bool> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String errorType,
    bool showRetry = true,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    HapticFeedback.mediumImpact();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  _getIconForErrorType(errorType),
                  color: _getColorForErrorType(errorType),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(fontSize: 14, height: 1.4)),
                SizedBox(height: 16),

                // Error type specific information
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getColorForErrorType(errorType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getColorForErrorType(errorType).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getErrorTypeDisplayName(errorType),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: _getColorForErrorType(errorType),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getErrorTypeDescription(errorType),
                        style: TextStyle(fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),

                // Progress preservation notice
                if (errorType == 'network' || errorType == 'server') ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.save_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your progress has been saved locally',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (onCancel != null)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                    onCancel();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              if (showRetry)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                    if (onRetry != null) onRetry();
                  },
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getColorForErrorType(errorType),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('OK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
    );

    return result ?? false;
  }

  // Handle network errors with automatic retry
  static Future<T?> handleNetworkOperation<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    required String operationName,
    bool showLoadingDialog = true,
    int maxRetries = maxRetries,
  }) async {
    int retryCount = 0;
    Exception? lastError;

    // Check network connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await showErrorDialog(
        context: context,
        title: 'No Internet Connection',
        message: 'Please check your internet connection and try again.',
        errorType: 'network',
        showRetry: false,
      );
      return null;
    }

    if (showLoadingDialog) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildLoadingDialog(operationName),
      );
    }

    while (retryCount < maxRetries) {
      try {
        final result = await operation();

        if (showLoadingDialog && Navigator.canPop(context)) {
          Navigator.pop(context); // Close loading dialog
        }

        return result;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        retryCount++;

        print('❌ Attempt $retryCount failed: $e');

        if (retryCount < maxRetries) {
          // Wait before retry with exponential backoff
          await Future.delayed(baseRetryDelay * retryCount);
        }
      }
    }

    // All retries failed
    if (showLoadingDialog && Navigator.canPop(context)) {
      Navigator.pop(context); // Close loading dialog
    }

    final shouldRetry = await showErrorDialog(
      context: context,
      title: '$operationName Failed',
      message: _getErrorMessage(lastError),
      errorType: _categorizeError(lastError),
      onRetry:
          () => handleNetworkOperation(
            context: context,
            operation: operation,
            operationName: operationName,
            showLoadingDialog: showLoadingDialog,
            maxRetries: maxRetries,
          ),
    );

    if (shouldRetry) {
      return handleNetworkOperation(
        context: context,
        operation: operation,
        operationName: operationName,
        showLoadingDialog: showLoadingDialog,
        maxRetries: maxRetries,
      );
    }

    return null;
  }

  // Handle validation errors
  static void showValidationError({
    required BuildContext context,
    required List<String> errors,
    String? customTitle,
  }) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: AppColors.warning,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(customTitle ?? 'Validation Error'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errors.length == 1
                      ? 'Please fix the following issue:'
                      : 'Please fix the following issues:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 12),
                ...errors
                    .map(
                      (error) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: TextStyle(fontSize: 13, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Got it'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  // Show success feedback
  static void showSuccessMessage({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Show progress feedback
  static void showProgressUpdate({
    required BuildContext context,
    required String message,
    double? progress,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (progress != null) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ] else
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Emergency exit with data preservation
  static Future<void> emergencyExit({
    required BuildContext context,
    required String reason,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Try to save current state
      // await RegistrationFlowManager.createBackup(
      //   // You'll need to pass the current registration data here
      //   // This is a placeholder - implement based on your needs
      // );

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 24),
                  SizedBox(width: 12),
                  Text('Session Interrupted'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'The registration process was interrupted due to: $reason',
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_done,
                          color: AppColors.success,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your progress has been saved and you can resume later.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to safe screen (home or main)
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  child: Text('Go to Home'),
                ),
              ],
            ),
      );
    } catch (e) {
      print('❌ Emergency exit failed: $e');
      // Force navigation to safe screen
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  // Helper methods
  static Widget _buildLoadingDialog(String operationName) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              operationName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _getIconForErrorType(String errorType) {
    switch (errorType) {
      case 'network':
        return Icons.wifi_off;
      case 'server':
        return Icons.cloud_off;
      case 'validation':
        return Icons.warning_outlined;
      case 'permission':
        return Icons.lock_outlined;
      case 'storage':
        return Icons.storage;
      default:
        return Icons.error_outline;
    }
  }

  static Color _getColorForErrorType(String errorType) {
    switch (errorType) {
      case 'network':
        return Colors.orange;
      case 'server':
        return Colors.red;
      case 'validation':
        return AppColors.warning;
      case 'permission':
        return Colors.purple;
      case 'storage':
        return Colors.blue;
      default:
        return AppColors.error;
    }
  }

  static String _getErrorTypeDisplayName(String errorType) {
    switch (errorType) {
      case 'network':
        return 'Network Issue';
      case 'server':
        return 'Server Error';
      case 'validation':
        return 'Validation Error';
      case 'permission':
        return 'Permission Error';
      case 'storage':
        return 'Storage Error';
      default:
        return 'Unknown Error';
    }
  }

  static String _getErrorTypeDescription(String errorType) {
    switch (errorType) {
      case 'network':
        return 'Check your internet connection and try again.';
      case 'server':
        return 'The server is experiencing issues. Please try again later.';
      case 'validation':
        return 'Please check your input and try again.';
      case 'permission':
        return 'Required permissions are missing.';
      case 'storage':
        return 'Unable to save data locally.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  static String _categorizeError(Exception? error) {
    if (error == null) return 'unknown';

    final message = error.toString().toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return 'network';
    } else if (message.contains('server') || message.contains('http')) {
      return 'server';
    } else if (message.contains('permission')) {
      return 'permission';
    } else if (message.contains('storage') || message.contains('disk')) {
      return 'storage';
    } else if (message.contains('validation') || message.contains('invalid')) {
      return 'validation';
    }

    return 'unknown';
  }

  static String _getErrorMessage(Exception? error) {
    if (error == null) return 'An unknown error occurred.';

    final message = error.toString();

    // Clean up technical error messages for user display
    if (message.contains('SocketException')) {
      return 'Network connection failed. Please check your internet and try again.';
    } else if (message.contains('TimeoutException')) {
      return 'The operation timed out. Please try again.';
    } else if (message.contains('FormatException')) {
      return 'Invalid data format received. Please try again.';
    } else if (message.contains('permission-denied')) {
      return 'You don\'t have permission to perform this action.';
    } else if (message.contains('unavailable')) {
      return 'The service is temporarily unavailable. Please try again later.';
    }

    return 'Something went wrong. Please try again.';
  }
}
