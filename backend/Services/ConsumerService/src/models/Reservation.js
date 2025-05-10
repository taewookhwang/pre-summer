const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');
const Service = require('./Service');

const Reservation = sequelize.define('Reservation', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id',
    references: {
      model: 'users', // User model from AuthService
      key: 'id'
    }
  },
  serviceId: {
    type: DataTypes.UUID,
    allowNull: false,
    field: 'service_id',
    references: {
      model: Service,
      key: 'id'
    }
  },
  technicianId: {
    type: DataTypes.INTEGER,
    allowNull: true, // Can be null when initially creating a reservation
    field: 'technician_id',
    references: {
      model: 'users',
      key: 'id'
    }
  },
  scheduledTime: {
    type: DataTypes.DATE,
    allowNull: false,
    field: 'scheduled_time'
  },
  status: {
    type: DataTypes.ENUM('pending', 'searching_technician', 'technician_assigned', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'pending'
  },
  // 주소 정보
  street: {
    type: DataTypes.STRING,
    allowNull: false
  },
  detail: {
    type: DataTypes.STRING,
    allowNull: true
  },
  postalCode: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'postal_code'
  },
  // 좌표 정보
  latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true
  },
  longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true
  },
  specialInstructions: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'special_instructions'
  },
  // 선택한 옵션들 (JSON 형태로 저장)
  serviceOptions: {
    type: DataTypes.JSON,
    allowNull: true,
    field: 'service_options'
  },
  // 커스텀 필드 값들 (JSON 형태로 저장)
  customFields: {
    type: DataTypes.JSON,
    allowNull: true,
    field: 'custom_fields'
  },
  estimatedPrice: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    field: 'estimated_price'
  },
  estimatedDuration: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'estimated_duration'
  },
  paymentStatus: {
    type: DataTypes.ENUM('pending', 'paid', 'refunded'),
    defaultValue: 'pending',
    field: 'payment_status'
  },
  currentStep: {
    type: DataTypes.ENUM('pending_payment', 'finding_technician', 'technician_assigned', 'technician_on_way', 'service_in_progress', 'service_completed'),
    defaultValue: 'pending_payment',
    field: 'current_step'
  }
}, {
  timestamps: true,
  tableName: 'reservations',
  indexes: [
    {
      name: 'reservations_user_id_idx',
      fields: ['user_id']
    },
    {
      name: 'reservations_service_id_idx',
      fields: ['service_id']
    },
    {
      name: 'reservations_technician_id_idx',
      fields: ['technician_id']
    },
    {
      name: 'reservations_status_idx',
      fields: ['status']
    },
    {
      name: 'reservations_scheduled_time_idx',
      fields: ['scheduled_time']
    }
  ]
});

// Define associations
Reservation.belongsTo(Service, { foreignKey: 'serviceId' });

module.exports = Reservation;