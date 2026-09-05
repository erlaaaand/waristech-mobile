import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

class VaultHeader extends StatelessWidget {
  final bool isRevealed;
  final VoidCallback onToggle;
  const VaultHeader({
    super.key,
    required this.isRevealed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Text(
              'Brankas',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.44,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isRevealed
                    ? ink
                    : (isDark ? AppColors.darkCard : Colors.white),
                border: Border.all(
                  color: isRevealed
                      ? ink
                      : (isDark ? AppColors.gray700 : AppColors.gray300),
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRevealed ? Icons.lock_open : Icons.fingerprint,
                    size: 18,
                    color: isRevealed
                        ? (isDark ? Colors.black : Colors.white)
                        : ink,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isRevealed ? 'Terkunci' : 'Buka Kunci',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isRevealed
                          ? (isDark ? Colors.black : Colors.white)
                          : ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MaskInfoBanner extends StatelessWidget {
  const MaskInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.gray50,
          border: Border.all(
            color: isDark ? AppColors.gray800 : AppColors.gray200,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.gray500),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Identitas akun tersamarkan. Ketuk "Buka Kunci" untuk menampilkan.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const SearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (v) => onChanged(v.toLowerCase()),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Cari aset...',
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray400,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.gray400,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : AppColors.gray50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isDark ? AppColors.gray800 : AppColors.gray200,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isDark ? AppColors.gray800 : AppColors.gray200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
