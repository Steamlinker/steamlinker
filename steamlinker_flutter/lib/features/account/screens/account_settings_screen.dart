import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../widgets/steam_app_bar.dart';
import '../../../widgets/steam_card.dart';
import '../../../widgets/validated_field.dart';
import '../../../widgets/strength_bar.dart';
import '../../../widgets/steam_buttons.dart';
import '../../../widgets/toggle_row.dart';
import '../../../widgets/drop_field.dart';
import '../../../widgets/steam_toast.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: const SteamAppBar(title: 'CONFIGURACIÓN DE CUENTA'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ProfileCard(),
          SizedBox(height: 16),
          _SecurityCard(),
          SizedBox(height: 16),
          _PrivacyCard(),
          SizedBox(height: 16),
          _DangerCard(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Tarjeta: Información personal ────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return SteamCard(
      icon: Icons.person_outline,
      title: 'Información Personal',
      child: Column(children: [
        // Fila: usuario + nombre visible
        Row(children: [
          Expanded(
            child: ValidatedField(
              label: 'Usuario',
              placeholder: 'usuario_ejemplo',
              initialValue: 'usuario_ejemplo',
              validator: (v) {
                if (v.length < 4) return 'Mínimo 4 caracteres';
                if (v.contains(' ')) return 'Sin espacios';
                if (!RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(v))
                  return 'Solo letras, números, _ y -';
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValidatedField(
              label: 'Nombre visible',
              placeholder: 'Tu nombre',
              initialValue: 'Gamer',
              validator: (v) =>
                  v.length > 32 ? 'Máximo 32 caracteres (${v.length}/32)' : null,
            ),
          ),
        ]),

        // Correo
        ValidatedField(
          label: 'Correo electrónico',
          placeholder: 'gamer@correo.com',
          initialValue: 'usuario@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)
                  ? null
                  : 'Formato de correo incorrecto',
        ),

        // País + idioma
        Row(children: [
          Expanded(
            child: DropField(
              label: 'País',
              value: 'Colombia',
              items: ['Colombia', 'México', 'Argentina', 'España', 'EE.UU.'],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropField(
              label: 'Idioma',
              value: 'Español',
              items: ['Español', 'English', 'Português', 'Français'],
            ),
          ),
        ]),

        const Divider(color: SteamColors.border, height: 1),
        const SizedBox(height: 12),

        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          SteamButtonOutline(
            label: 'Cancelar',
            onTap: () {},
          ),
          const SizedBox(width: 10),
          SteamButtonPrimary(
            label: 'Guardar',
            icon: Icons.save_outlined,
            onTap: (ctx) =>
                showSteamToast(ctx, 'Perfil guardado correctamente', SteamColors.green),
          ),
        ]),
      ]),
    );
  }
}

// ── Tarjeta: Seguridad ───────────────────────────────────────────────────
class _SecurityCard extends StatefulWidget {
  const _SecurityCard();

  @override
  State<_SecurityCard> createState() => _SecurityCardState();
}

class _SecurityCardState extends State<_SecurityCard> {
  String _newPw = '';

  @override
  Widget build(BuildContext context) {
    return SteamCard(
      icon: Icons.lock_outline,
      title: 'Seguridad',
      child: Column(children: [
        // Contraseña actual
        ValidatedField(
          label: 'Contraseña actual',
          placeholder: '••••••••',
          obscure: true,
          validator: (v) =>
              v.length < 6 ? 'Contraseña incorrecta' : null,
        ),

        // Nueva contraseña
        ValidatedField(
          label: 'Nueva contraseña',
          placeholder: 'Mínimo 8 caracteres',
          obscure: true,
          validator: (v) =>
              v.length < 8 ? 'Mínimo 8 caracteres' : null,
          onChanged: (v, _) => setState(() => _newPw = v),
          extra: StrengthBar(password: _newPw),
        ),

        // Confirmar contraseña
        ValidatedField(
          label: 'Confirmar contraseña',
          placeholder: 'Repite la contraseña',
          obscure: true,
          validator: (v) =>
              v != _newPw ? 'Las contraseñas no coinciden' : null,
        ),

        const Divider(color: SteamColors.border, height: 1),
        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: SteamButtonPrimary(
            label: 'Actualizar contraseña',
            icon: Icons.lock_reset_outlined,
            onTap: (ctx) => showSteamToast(
                ctx, 'Contraseña actualizada correctamente', SteamColors.green),
          ),
        ),
      ]),
    );
  }
}

// ── Tarjeta: Privacidad ──────────────────────────────────────────────────
class _PrivacyCard extends StatefulWidget {
  const _PrivacyCard();

  @override
  State<_PrivacyCard> createState() => _PrivacyCardState();
}

class _PrivacyCardState extends State<_PrivacyCard> {
  bool publicProfile = true;
  bool friendNotifs  = true;
  bool twoFA         = false;
  bool promoEmails   = true;

  @override
  Widget build(BuildContext context) {
    return SteamCard(
      icon: Icons.shield_outlined,
      title: 'Privacidad y Notificaciones',
      child: Column(children: [
        ToggleRow(
          title: 'Perfil público',
          description: 'Otros jugadores pueden ver tu perfil y biblioteca',
          value: publicProfile,
          onChanged: (v) => setState(() => publicProfile = v),
        ),
        ToggleRow(
          title: 'Notificaciones de amigos',
          description: 'Alerta cuando tus amigos se conecten',
          value: friendNotifs,
          onChanged: (v) => setState(() => friendNotifs = v),
        ),
        ToggleRow(
          title: 'Autenticación en dos pasos',
          description: 'Capa extra de seguridad para tu cuenta',
          value: twoFA,
          onChanged: (v) => setState(() => twoFA = v),
        ),
        ToggleRow(
          title: 'Correos promocionales',
          description: 'Recibe ofertas y novedades de la tienda',
          value: promoEmails,
          onChanged: (v) => setState(() => promoEmails = v),
          showDivider: false,
        ),
      ]),
    );
  }
}

// ── Tarjeta: Zona de peligro ─────────────────────────────────────────────
class _DangerCard extends StatelessWidget {
  const _DangerCard();

  @override
  Widget build(BuildContext context) {
    return SteamCard(
      icon: Icons.warning_amber_outlined,
      title: 'Zona de Peligro',
      accent: SteamColors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estas acciones son irreversibles. Procede con precaución.',
            style: TextStyle(color: SteamColors.textSec, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: [
            SteamButtonDanger(
              label: 'Suspender Cuenta',
              icon: Icons.block_outlined,
              onTap: () => _confirmDialog(context, 'suspender'),
            ),
            SteamButtonDanger(
              label: 'Eliminar Cuenta',
              icon: Icons.delete_forever_outlined,
              onTap: () => _confirmDialog(context, 'eliminar permanentemente'),
            ),
          ]),
        ],
      ),
    );
  }

  void _confirmDialog(BuildContext ctx, String action) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: SteamColors.bgPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: SteamColors.red),
        ),
        title: const Text(
          '¿Estás seguro?',
          style: TextStyle(
              color: SteamColors.light, fontWeight: FontWeight.w800),
        ),
        content: Text(
          '¿Deseas $action tu cuenta? Esta acción no se puede deshacer.',
          style: const TextStyle(color: SteamColors.textSec, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: SteamColors.muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
                backgroundColor: SteamColors.red),
            child: const Text('Confirmar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
