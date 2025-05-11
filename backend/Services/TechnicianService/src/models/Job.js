const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');

const Job = sequelize.define(
  'Job',
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    reservationId: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: true,
      comment: 'References the reservation this job is created from',
    },
    technicianId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'users', // User model from AuthService
        key: 'id',
      },
    },
    consumerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'users', // User model from AuthService
        key: 'id',
      },
    },
    serviceId: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    scheduledDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    startTime: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'When the technician started the job',
    },
    endTime: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'When the technician finished the job',
    },
    status: {
      type: DataTypes.ENUM('assigned', 'en_route', 'in_progress', 'completed', 'cancelled'),
      defaultValue: 'assigned',
    },
    address: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true,
      comment: 'Technician notes about the job',
    },
    completionPhotos: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      allowNull: true,
      comment: 'URLs of photos taken after job completion',
    },
    earnings: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      comment: 'Amount earned by technician for this job',
    },
    rating: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 1,
        max: 5,
      },
      comment: 'Rating given by the consumer (1-5)',
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    updatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    timestamps: true,
    indexes: [
      {
        name: 'jobs_technician_id_idx',
        fields: ['technicianId'],
      },
      {
        name: 'jobs_consumer_id_idx',
        fields: ['consumerId'],
      },
      {
        name: 'jobs_status_idx',
        fields: ['status'],
      },
      {
        name: 'jobs_scheduled_date_idx',
        fields: ['scheduledDate'],
      },
    ],
  },
);

module.exports = Job;
