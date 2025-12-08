import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact section widget – UI‑only (no backend). Drop into Flutter Web site.
/// ────────────────────────────────────────────────────────────────────────────
/// ⚠️  If you want to hook the form to an email service / API later, simply
///      replace the `onPressed` callback on the Send button.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _SectionTitle(palette: palette),
                const SizedBox(height: 32),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: ContactFormCard(palette: palette)),
                      const SizedBox(width: 32), // Separación entre las columnas
                      Expanded(flex: 4, child: _ContactInfoPanel(palette: palette)),
                    ],
                  )

                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContactFormCard(palette: palette),

                      const SizedBox(height: 32),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: _ContactInfoPanel(palette: palette),
                      ),
                    ],
                  ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  _Palette _palette(BuildContext context) {
    final theme = Theme.of(context);
    return _Palette(
      primary: theme.colorScheme.primary,
      subtitle: theme.textTheme.bodyMedium?.color ?? Colors.grey.shade700,
      inputBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////
//  COMPONENTS                                                     //
//////////////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final _Palette palette;
  const _SectionTitle({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Contacto',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(height: 4, width: 80, color: palette.primary),
        const SizedBox(height: 16),
        Text(
          '¿Tienes alguna pregunta o propuesta? ¡No dudes en contactarme!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.subtitle,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ContactFormCard extends StatefulWidget {
  final _Palette palette;
  const ContactFormCard({super.key, required this.palette});

  @override
  State<ContactFormCard> createState() => _ContactFormCardState();
}

class _ContactFormCardState extends State<ContactFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);
    final now = DateTime.now();
    try {
      await FirebaseFirestore.instance.collection('contact_messages').add({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
        'createdAt': now.toIso8601String(),
      });
      _formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mensaje enviado. ¡Gracias!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar (intenta de nuevo): $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;

    InputBorder _border(Color c) => p.inputBorder.copyWith(borderSide: BorderSide(color: c));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Envíame un mensaje', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              // Nombre ---------------------------------------------------
              _Label('Nombre', palette: p),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: _decoration('Tu nombre', p),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 20),
              // Email ----------------------------------------------------
              _Label('Correo electrónico', palette: p),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                decoration: _decoration('Tu correo electrónico', p),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                  final emailRx = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
                  return emailRx.hasMatch(v.trim()) ? null : 'Correo no válido';
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Mensaje --------------------------------------------------
              _Label('Mensaje', palette: p),
              const SizedBox(height: 6),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 6,
                decoration: _decoration('Tu mensaje', p),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe tu mensaje' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _sending ? null : _submit,
                  icon: _sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                  label: const Text('Enviar mensaje'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, _Palette p) => InputDecoration(
    hintText: hint,
    border: p.inputBorder,
    enabledBorder: p.inputBorder,
    focusedBorder: p.inputBorder.copyWith(borderSide: BorderSide(color: p.primary)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.palette});
  final String text;
  final _Palette palette;
  @override
  Widget build(BuildContext context) => Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500));
}

class _ContactInfoPanel extends StatelessWidget {
  final _Palette palette;
  const _ContactInfoPanel({required this.palette});

  @override
  Widget build(BuildContext context) {
    final infoStyle = Theme.of(context).textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información de contacto',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 24),
        _InfoRow(
          icon: Icons.email, label: 'Email', lines: [
          'josiasjofre@gmail.com',
          'josiasjofre@alu.unach.cl',
        ], infoStyle: infoStyle,
        ),
        const SizedBox(height: 20),
        _InfoRow(
          icon: Icons.phone, label: 'Teléfono', lines: ['+56 9 6727 9093'], infoStyle: infoStyle,
        ),
        const SizedBox(height: 20),
        _InfoRow(
          icon: Icons.location_on, label: 'Ubicación', lines: [
          'Chillán, Región de Ñuble, Chile'
        ], infoStyle: infoStyle,
        ),
        const SizedBox(height: 32),
        Text('Redes Sociales',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          children: [
            _SocialCircle(icon: FontAwesomeIcons.github, url: 'https://github.com/JotaWindus'),
            _SocialCircle(icon: FontAwesomeIcons.linkedin, url: 'https://www.linkedin.com/in/josias-alexis-jofre-pol-a98688341/'),
            _SocialCircle(icon: FontAwesomeIcons.instagram, url: 'https://www.instagram.com/iamjosiah.cl/'),
            _SocialCircle(icon: Icons.email_outlined, url: 'mailto:josiasjofre@gmail.com'),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> lines;
  final TextStyle? infoStyle;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.lines,
    required this.infoStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              ...lines.map((l) {
                if (l.contains('6727')) {
                  final parts = l.split('6727');
                  return RichText(
                    text: TextSpan(
                      style: infoStyle,
                      children: [
                        TextSpan(text: parts[0]),
                        TextSpan(
                          text: '6727',
                          style: infoStyle?.copyWith(
                            color: Color(0xFF003366), // Azul marino
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: parts.length > 1 ? parts[1] : ''),
                      ],
                    ),
                  );
                } else {
                  return Text(l, style: infoStyle);
                }
              }),


            ],
          ),
        ),
      ],
    );
  }
}



/// Local widget for social media links with hover effect
class _SocialCircle extends StatefulWidget {
  final IconData icon;
  final String url;
  const _SocialCircle({required this.icon, required this.url});

  @override
  State<_SocialCircle> createState() => _SocialCircleState();
}

class _SocialCircleState extends State<_SocialCircle> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // Normal state
    final bgColor = _isHovering ? primary : Colors.grey.shade200;
    final iconColor = _isHovering ? Colors.white : Colors.grey.shade800;
    final scale = _isHovering ? 1.1 : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo abrir el enlace.')),
              );
            }
          }
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: bgColor,
            child: Icon(widget.icon, color: iconColor),
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////
//  PALETTE                                                        //
//////////////////////////////////////////////////////////////////////

class _Palette {
  final Color primary;
  final Color subtitle;
  final OutlineInputBorder inputBorder;
  const _Palette({
    required this.primary,
    required this.subtitle,
    required this.inputBorder,
  });
}
