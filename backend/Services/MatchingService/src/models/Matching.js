const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');

const Matching = sequelize.define(
  'Matching',
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    reservationId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'reservation_id',
    },
    status: {
      type: DataTypes.ENUM(
        'pending',
        'searching',
        'technician_found',
        'technician_requested',
        'matched',
        'cancelled',
        'expired',
        'failed',
      ),
      defaultValue: 'pending',
    },
    attempts: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    technicianId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      field: 'technician_id',
    },
    searchRadius: {
      type: DataTypes.FLOAT,
      defaultValue: 3.0, // 기본 검색 반경 3km
      field: 'search_radius',
    },
    maxDistance: {
      type: DataTypes.FLOAT,
      defaultValue: 10.0, // 최대 검색 반경 10km
      field: 'max_distance',
    },
    priorityFactors: {
      type: DataTypes.JSON,
      defaultValue: ['distance', 'rating', 'experience'],
      field: 'priority_factors',
    },
    matchedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'matched_at',
    },
    estimatedArrival: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'estimated_arrival',
    },
    requestExpiry: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'request_expiry',
    },
  },
  {
    timestamps: true,
    tableName: 'matchings',
    indexes: [
      {
        name: 'matchings_reservation_id_idx',
        fields: ['reservation_id'],
      },
      {
        name: 'matchings_technician_id_idx',
        fields: ['technician_id'],
      },
      {
        name: 'matchings_status_idx',
        fields: ['status'],
      },
    ],
  },
);

module.exports = Matching;
