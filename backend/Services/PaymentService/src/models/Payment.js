const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');

const Payment = sequelize.define(
  'Payment',
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
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'user_id',
    },
    amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    paymentMethod: {
      type: DataTypes.ENUM('card', 'vbank', 'phone'),
      allowNull: false,
      field: 'payment_method',
    },
    paymentDetails: {
      type: DataTypes.JSON,
      allowNull: true,
      field: 'payment_details',
    },
    status: {
      type: DataTypes.ENUM('pending', 'paid', 'cancelled', 'refunded', 'failed'),
      defaultValue: 'pending',
    },
    paymentUrl: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'payment_url',
    },
    transactionId: {
      type: DataTypes.STRING,
      allowNull: true,
      field: 'transaction_id',
    },
  },
  {
    timestamps: true,
    tableName: 'payments',
    indexes: [
      {
        name: 'payments_reservation_id_idx',
        fields: ['reservation_id'],
      },
      {
        name: 'payments_user_id_idx',
        fields: ['user_id'],
      },
      {
        name: 'payments_status_idx',
        fields: ['status'],
      },
    ],
  },
);

module.exports = Payment;
