import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/vehicle.dart';
import '../../repositories/vehicle/vehicle_repository.dart';
import 'vehicle_form_screen.dart';

/// Lista de veículos cadastrados pelo transportador (seções 7 e 28 do
/// escopo de Fretes, Entregas e Transportes).
class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final _vehicleRepo = VehicleRepository();

  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _vehicleRepo.getMyVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openForm({Vehicle? vehicle}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: vehicle)),
    );
    if (result == true) _loadVehicles();
  }

  Future<void> _handleSetDefault(Vehicle vehicle) async {
    final success = await _vehicleRepo.setDefault(vehicle.id);
    if (success) _loadVehicles();
  }

  Future<void> _handleDelete(Vehicle vehicle) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Remover veículo?',
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '${vehicle.brand} ${vehicle.model} • ${vehicle.plateNumber}',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Remover', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      final success = await _vehicleRepo.delete(vehicle.id);
      if (success) _loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Meus Veículos',
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
        label: Text(
          'Adicionar',
          style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : _vehicles.isEmpty
                ? _buildEmptyState()
                : _buildVehicleList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadVehicles,
      color: AppColors.primaryGold,
      backgroundColor: AppColors.cardBackground,
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.local_shipping_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Você ainda não cadastrou nenhum veículo',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Cadastre um veículo para receber oportunidades de frete',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList() {
    return RefreshIndicator(
      onRefresh: _loadVehicles,
      color: AppColors.primaryGold,
      backgroundColor: AppColors.cardBackground,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) => _buildVehicleCard(_vehicles[index]),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final status = vehicle.approvalStatus.toLowerCase();
    final isApproved = status == 'approved' || status == 'approve';
    final isRejected = status == 'rejected' || status == 'reject';
    final statusColor = isApproved ? AppColors.success : (isRejected ? AppColors.errorRed : AppColors.warning);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: vehicle.isDefault ? AppColors.primaryGold.withValues(alpha: 0.6) : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: vehicle.photoUrl.isNotEmpty
                      ? Image.network(
                          vehicle.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.local_shipping_outlined, color: AppColors.textMuted),
                        )
                      : const Icon(Icons.local_shipping_outlined, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}'.trim(),
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${vehicle.vehicleType} • ${vehicle.plateNumber}${vehicle.year > 0 ? ' • ${vehicle.year}' : ''}',
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.cardBackground,
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                onSelected: (value) {
                  if (value == 'edit') _openForm(vehicle: vehicle);
                  if (value == 'default') _handleSetDefault(vehicle);
                  if (value == 'delete') _handleDelete(vehicle);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  if (!vehicle.isDefault) const PopupMenuItem(value: 'default', child: Text('Definir como padrão')),
                  const PopupMenuItem(value: 'delete', child: Text('Remover')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (vehicle.isDefault)
                _buildBadge('Padrão', AppColors.primaryGold, Icons.star_rounded),
              _buildBadge(vehicle.approvalStatusLabel, statusColor, null),
              if (!vehicle.isActive)
                _buildBadge('Inativo', AppColors.textMuted, Icons.block_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
          ],
          Text(label, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}