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
    references: {
      model: 'users', // User model from AuthService
      key: 'id'
    }
  },
  serviceId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: Service,
      key: 'id'
    }
  },
  technicianId: {
    type: DataTypes.INTEGER,
    allowNull: true, // Can be null when initially creating a reservation
    references: {
      model: 'users',
      key: 'id'
    }
  },
  reservationDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'pending'
  },
  address: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  specialInstructions: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  totalPrice: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  paymentStatus: {
    type: DataTypes.ENUM('pending', 'paid', 'refunded'),
    defaultValue: 'pending'
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  updatedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  timestamps: true,
  indexes: [
    {
      name: 'reservations_user_id_idx',
      fields: ['userId']
    },
    {
      name: 'reservations_service_id_idx',
      fields: ['serviceId']
    },
    {
      name: 'reservations_technician_id_idx',
      fields: ['technicianId']
    },
    {
      name: 'reservations_status_idx',
      fields: ['status']
    },
    {
      name: 'reservations_date_idx',
      fields: ['reservationDate']
    }
  ]
});

// Define associations
Reservation.belongsTo(Service, { foreignKey: 'serviceId' });

module.exports = Reservation;