const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');
const Matching = require('./Matching');

const MatchingRequest = sequelize.define(
  'MatchingRequest',
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    matchingId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'matching_id',
      references: {
        model: Matching,
        key: 'id',
      },
    },
    technicianId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'technician_id',
    },
    status: {
      type: DataTypes.ENUM('pending', 'accepted', 'declined', 'expired'),
      defaultValue: 'pending',
    },
    distance: {
      type: DataTypes.FLOAT,
      allowNull: true,
    },
    score: {
      type: DataTypes.FLOAT,
      allowNull: true,
      comment: '매칭 알고리즘에서 계산된 점수',
    },
    requestExpiry: {
      type: DataTypes.DATE,
      allowNull: false,
      field: 'request_expiry',
    },
    respondedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'responded_at',
    },
    declineReason: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'decline_reason',
    },
  },
  {
    timestamps: true,
    tableName: 'matching_requests',
    indexes: [
      {
        name: 'matching_requests_matching_id_idx',
        fields: ['matching_id'],
      },
      {
        name: 'matching_requests_technician_id_idx',
        fields: ['technician_id'],
      },
      {
        name: 'matching_requests_status_idx',
        fields: ['status'],
      },
    ],
  },
);

// 관계 설정
Matching.hasMany(MatchingRequest, { foreignKey: 'matchingId', as: 'requests' });
MatchingRequest.belongsTo(Matching, { foreignKey: 'matchingId', as: 'matching' });

module.exports = MatchingRequest;
