import 'package:flutter/material.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ModeloDetailsScreen extends StatelessWidget {
  final Model modelo;

  const ModeloDetailsScreen({Key? key, required this.modelo}) : super(key: key);

  Future<void> _launchCall(String phoneNumber) async {
    // Corrija o formato do número
    final String formattedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    
    // Crie a URI com o esquema correto
    final Uri launchUri = Uri.parse('tel:$formattedNumber');
    
    try {
      if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
        throw 'Não foi possível iniciar a ligação';
      }
    } catch (e) {
      debugPrint('Erro ao tentar ligar: $e');
      // Mostre um snackbar para o usuário
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Não foi possível ligar para $phoneNumber')),
      );
    }
  }

  // Chave global para acessar o Scaffold a partir de métodos estáticos
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      key: scaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.4,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                modelo.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black54,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  modelo.fileKey != null
                      ? CachedNetworkImage(
                          imageUrl: '${ApiConfig.apiBaseUrl}/files/${modelo.fileKey}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  const SizedBox(height: 20),
                  _buildAgencyCard(context),
                  const SizedBox(height: 20),
                  _buildContactButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações do Modelo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(),
            _buildInfoRow(Icons.height, 'Altura', modelo.height),
            _buildInfoRow(Icons.straighten, 'Cintura', modelo.waist),
            _buildInfoRow(Icons.shopping_bag, 'Calçado', modelo.shoes), 
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agência',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(),
            _buildInfoRow(Icons.business, 'Nome', modelo.agency!.name), 
            if (modelo.agency!.contact != null)
              _buildInfoRow(Icons.phone, 'contact', modelo.agency!.contact ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _showContactOptions(context, modelo.agency!.contact, "agência"),
          icon: const Icon(Icons.business),
          label: const Text('Contatar Agência'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _showContactOptions(BuildContext context, String contact, String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contatar $type',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green),
                title: Text('Ligar para $type'),
                subtitle: Text(contact),
                onTap: () {
                  Navigator.pop(context);
                  _launchCall(contact);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message, color: Colors.blue),
                title: Text('Enviar SMS para $type'),
                subtitle: Text(contact),
                onTap: () {
                  Navigator.pop(context);
                  _launchSMS(contact);
                },
              ), 
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchSMS(String phoneNumber) async {
    final String formattedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri smsUri = Uri.parse('sms:$formattedNumber');
    
    try {
      if (!await launchUrl(smsUri)) {
        throw 'Não foi possível enviar SMS';
      }
    } catch (e) {
      debugPrint('Erro ao tentar enviar SMS: $e');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Não foi possível enviar SMS para $phoneNumber')),
      );
    }
  }

  Future<void> _shareContact(String phoneNumber, String type) async {
    // Aqui você pode implementar o compartilhamento do contato
    // usando um plugin como share_plus
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
      SnackBar(content: Text('Função de compartilhar contato do $type não implementada')),
    );
  }
}