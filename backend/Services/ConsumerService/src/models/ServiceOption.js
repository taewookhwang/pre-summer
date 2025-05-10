const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');
const Service = require('./Service');

const ServiceOption = sequelize.define('ServiceOption', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
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
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    field: 'is_active'
  }
}, {
  timestamps: true,
  tableName: 'service_options'
});

// Define associations
ServiceOption.belongsTo(Service, { foreignKey: 'serviceId' });
Service.hasMany(ServiceOption, { foreignKey: 'serviceId', as: 'options' });

module.exports = ServiceOption;